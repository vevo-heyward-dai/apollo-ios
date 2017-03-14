//
//  VMApollo.swift
//  Apollo
//
//  Created by SterlingVevo on 3/13/17.
//

import Foundation

public typealias VMResponseHandler = (_ result: JSONObject?, _ error: Error?) -> Void

extension ApolloClient {
    
    /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
    @discardableResult public func vm_fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: VMResponseHandler?) -> Cancellable {
        
        // If we don't have to go through the cache, there is no need to create an operation
        // and we can return a network task directly
        //        if cachePolicy == .fetchIgnoringCacheData {
        return vm_send(operation: query, context: nil, handlerQueue: queue, resultHandler: resultHandler)
        //        } else {
        //            let operation = FetchQueryOperation(client: self, query: query, cachePolicy: cachePolicy, context: context, handlerQueue: queue, resultHandler: resultHandler)
        //            operationQueue.addOperation(operation)
        //            return operation
        //        }
    }
    
    /// Performs a mutation by sending it to the server.
    @discardableResult public func vm_perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = DispatchQueue.main, resultHandler: VMResponseHandler?) -> Cancellable {
        return vm_send(operation: mutation, context: nil, handlerQueue: queue, resultHandler: resultHandler)
    }
    
    fileprivate func vm_send<Operation: GraphQLOperation>(operation: Operation, context: UnsafeMutableRawPointer?, handlerQueue: DispatchQueue, resultHandler: VMResponseHandler?) -> Cancellable {
        
        
        
        func notifyResultHandler(result: GraphQLResponse<Operation>?, error: Error?) {
            guard let resultHandler = resultHandler else { return }
            
            handlerQueue.async {
                resultHandler(result?.body, error)
            }
        }
        
        return networkTransport.send(operation: operation) { (response, error) in
            guard let response = response else {
                notifyResultHandler(result: nil, error: error)
                return
            }
            
            notifyResultHandler(result: response, error: error)
            //                do {
            //                    let (result, records) = try response.parseResult(cacheKeyForObject: self.cacheKeyForObject)
            //
            //                    notifyResultHandler(result: result, error: nil)
            //
            //                    if let records = records {
            //                        self.store.publish(records: records, context: context)
            //                    }
            //                } catch {
            //                    notifyResultHandler(result: nil, error: error)
            //                }
            //            }
        }
    }
}
