//
//  PhotosModel.swift
//  VirtualTourist
//
//  Created by Darin Williams on 5/25/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

struct FlickerResponse: Codable {
    let photos: PublicPhoto?
    let stat: String?
    
}

struct PublicPhoto: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: String?
    let photo: [MyPhoto]?
}

struct MyPhoto: Codable {
    let id: String?
    let owner: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    let ispublic, isfriend, isfamily: Int?
    let urlZ: String?
    let heightZ: String?
    let widthZ: String?
    
    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
        case urlZ = "url_z"
        case heightZ = "height_z"
        case widthZ = "width_z"
    }
}

struct FlickrSearchPayload: Codable {
    let pageResults: SearchPageResult
    
    enum CodingKeys: String, CodingKey {
        case pageResults = "photo"
    }
}

struct SearchPageResult: Codable {
    let page, pages, perpage: Int?
    let total: String?
    let photoMeta: [PublicPhoto]?
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case photoMeta = "photo"
    }
}

