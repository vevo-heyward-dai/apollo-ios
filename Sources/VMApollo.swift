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
        
        return vm_send(operation: query, context: nil, handlerQueue: queue, resultHandler: resultHandler)
    }
    
    /// Performs a mutation by sending it to the server.
    @discardableResult public func vm_perform<Mutation: GraphQLMutation>(mutation: Mutation, queue: DispatchQueue = DispatchQueue.main, resultHandler: VMResponseHandler?) -> Cancellable {
        return vm_send(operation: mutation, context: nil, handlerQueue: queue, resultHandler: resultHandler)
    }
    
    /// Modified send function to intercept and return the plain JSON as JSONObject. This way we bypass Apollo's parsing flow as well as its caching logics.
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
        }
    }
}
