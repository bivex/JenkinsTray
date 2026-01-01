/**
 * Copyright (c) 2026 Bivex
 *
 * Author: Bivex
 * Available for contact via email: support@b-b.top
 * For up-to-date contact information:
 * https://github.com/bivex
 *
 * Created: 2026-01-01T17:40:45
 * Last Updated: 2026-01-01T18:27:24
 *
 * Licensed under the MIT License.
 * Commercial licensing available upon request.
 */

import Foundation
import Domain

/// Repository implementation for Jenkins builds using Jenkins API
public final class JenkinsBuildsRepository: BuildsRepository {
    private let httpClient: JenkinsHTTPClient
    private let jobPath: String

    public init(credentials: JenkinsCredentials, jobPath: String = "job/test-app/job/main") {
        self.httpClient = JenkinsHTTPClient(credentials: credentials)
        self.jobPath = jobPath
    }

    public func fetchBuilds() async throws -> [Build] {
        do {
            // Request build details with tree parameter to get all necessary fields
            let endpoint = "\(jobPath)/api/json?tree=builds[number,result,timestamp,duration,url]"
            let jobDTO: JenkinsJobDTO = try await httpClient.get(endpoint)

            return jobDTO.builds.compactMap { buildDTO in
                // Only include completed builds (those with a result)
                guard let resultString = buildDTO.result,
                      let result = BuildResult(rawValue: resultString) else {
                    return nil
                }

                guard let url = URL(string: buildDTO.url) else {
                    return nil
                }

                // Use optional values with defaults
                let timestamp = buildDTO.timestamp.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000) } ?? Date()
                let duration = buildDTO.duration.map { TimeInterval($0) / 1000 } ?? 0

                return Build(
                    id: buildDTO.number,
                    result: result,
                    timestamp: timestamp,
                    duration: duration,
                    url: url
                )
            }
        } catch let error as JenkinsHTTPError {
            throw BuildsRepositoryError.fromJenkinsHTTPError(error)
        } catch {
            throw BuildsRepositoryError.networkError(error)
        }
    }

    public func fetchBuildStages(for buildId: Int) async throws -> [BuildStage] {
        do {
            let workflowDTO: JenkinsWorkflowDTO = try await httpClient.get("\(jobPath)/\(buildId)/wfapi/describe")

            return workflowDTO.stages.map { stageDTO in
                let status = BuildStageStatus(rawValue: stageDTO.status) ?? .unknown

                return BuildStage(
                    id: stageDTO.id,
                    name: stageDTO.name,
                    status: status,
                    duration: stageDTO.durationMillis.map { TimeInterval($0) / 1000 } ?? 0, // Convert from milliseconds
                    startTimeMillis: stageDTO.startTimeMillis
                )
            }
        } catch let error as JenkinsHTTPError {
            switch error {
            case .notFound:
                throw BuildsRepositoryError.buildNotFound(buildId)
            default:
                throw BuildsRepositoryError.fromJenkinsHTTPError(error)
            }
        } catch {
            throw BuildsRepositoryError.networkError(error)
        }
    }

    /// Fetch list of available jobs from Jenkins
    public func fetchJobsList(path: String = "") async throws -> [String] {
        do {
            let endpoint = path.isEmpty ? "api/json?tree=jobs[name,url,class,jobs[name,url,class]]" : "\(path)/api/json?tree=jobs[name,url,class,jobs[name,url,class]]"

            #if DEBUG
            print("[JenkinsBuildsRepository] Fetching jobs from endpoint: \(endpoint)")
            #endif

            let response: JenkinsJobsListDTO = try await httpClient.get(endpoint)

            #if DEBUG
            print("[JenkinsBuildsRepository] Response received with \(response.jobs.count) root jobs")
            #endif

            var jobPaths: [String] = []

            func extractJobPaths(from jobs: [JenkinsJobItemDTO], prefix: String = "") {
                for job in jobs {
                    let currentPath = prefix.isEmpty ? "job/\(job.name)" : "\(prefix)/job/\(job.name)"

                    #if DEBUG
                    print("[JenkinsBuildsRepository] Processing job: \(job.name), class: \(job._class), has sub-jobs: \(job.jobs != nil)")
                    #endif

                    if let subJobs = job.jobs, !subJobs.isEmpty {
                        // This is a folder, recurse into it
                        #if DEBUG
                        print("[JenkinsBuildsRepository] Recursing into folder: \(currentPath) with \(subJobs.count) sub-jobs")
                        #endif
                        extractJobPaths(from: subJobs, prefix: currentPath)
                    } else {
                        // This is a job, add it to the list
                        #if DEBUG
                        print("[JenkinsBuildsRepository] Adding job path: \(currentPath)")
                        #endif
                        jobPaths.append(currentPath)
                    }
                }
            }

            extractJobPaths(from: response.jobs)

            #if DEBUG
            print("[JenkinsBuildsRepository] Total job paths found: \(jobPaths.count)")
            print("[JenkinsBuildsRepository] Job paths: \(jobPaths)")
            #endif

            return jobPaths.sorted()
        } catch let error as JenkinsHTTPError {
            #if DEBUG
            print("[JenkinsBuildsRepository] JenkinsHTTPError: \(error)")
            #endif
            throw BuildsRepositoryError.fromJenkinsHTTPError(error)
        } catch {
            #if DEBUG
            print("[JenkinsBuildsRepository] Error: \(error)")
            #endif
            throw BuildsRepositoryError.networkError(error)
        }
    }
}

private extension BuildsRepositoryError {
    static func fromJenkinsHTTPError(_ error: JenkinsHTTPError) -> BuildsRepositoryError {
        switch error {
        case .authenticationFailed, .forbidden:
            return .authenticationError
        case .notFound:
            return .invalidResponse
        case .serverError(let code, let message):
            return .serverError(code, message)
        case .decodingFailed, .invalidResponse, .unexpectedStatusCode:
            return .invalidResponse
        }
    }
}
