//
//  FirestoreAPI.swift
//  FindMyFriend
//
//  Created by mac on 6/16/19.
//  Copyright © 2019 NorensIKT. All rights reserved.
//

import FirebaseFirestore
import CodableFirebase

class FirestoreAPI {
    
    static let shared = FirestoreAPI()
    
    private let db: Firestore
    private let decoder = FirebaseDecoder()
    private let encoder = FirebaseEncoder()
    
    let users: CollectionReference
    
    enum Collection: String {
        case users = "users"
    }
    
    enum FirestoreError: LocalizedError {
        case errorFetchingDocuments(Error)
        case noDocumentsInQuery
        case parseError(Error)
        
        var localizedDescription: String {
            switch self {
            case .errorFetchingDocuments(let error):
                return "Error fetching documents: \(error)"
            case .noDocumentsInQuery:
                return "No documents where returned by given query"
            case .parseError(let error):
                return "Error while parsing result: \(error)"
            }
        }
    }
    
    init() {
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        
        let db = Firestore.firestore()
        db.settings = settings

        self.users = db.collection("users")
        self.db = db
    }
    
    func setUserData(_ userLocation: UserLocation) -> Bool {
        do {
            let data = try self.encoder.encode(userLocation)
            self.db.document("users/\(userLocation.id)").setData(data as! [String : Any])
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }
    
    func getDocumentID(_ path: String) -> String {
        return db.document(path).documentID
    }
    
    @discardableResult
    func subscribeToCollection(_ collection: Collection, completion: @escaping (FirestoreError?, [UserLocation]) -> Void) -> ListenerRegistration {
        return db.collection(collection.rawValue).addSnapshotListener { querySnapshot, error in
            
            if let error = error {
                completion(.errorFetchingDocuments(error), [])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.noDocumentsInQuery, [])
                return
            }
            
            do {
                let userLocations = try documents.map { (doc: DocumentSnapshot) throws -> UserLocation in
                    var docData = doc.data()!
                    docData["id"] = doc.documentID
                    return try self.decoder.decode(UserLocation.self, from: docData)
                }
                completion(nil, userLocations)
            } catch {
                completion(.parseError(error), [])
            }
        }
    }
}