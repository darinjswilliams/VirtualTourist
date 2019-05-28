//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Darin Williams on 5/15/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate  {
    
    var dataController:DataController!
    var pin: Pin!
    var coordinates: CLLocationCoordinate2D!
    var photos:[PublicPhoto] = [PublicPhoto]()
    var photoCount: Int = 0
    var photosImage = [UIImage]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayOut: UICollectionViewFlowLayout!
    @IBOutlet weak var labelNoPhotos: UILabel!
    @IBOutlet weak var newPhotosButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(coordinates.latitude)
         print(coordinates.longitude)
        print(pin)
        print(dataController)
    }

    //tear down NSfetchResultsController
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
 
        
    }
    
    //MARK: retrieve saved images from core data, else call flicker and get new photoz
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO; CALL FLICKER GET PHOTOS
               ParseFickrAPI.processPhotos(url: EndPoints.getAuthentication(coordinates.latitude, coordinates.longitude).url, completionHandler: handleGetFlickerPhotos(photos:error:))
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK Tapping this button should empty the photo album and fetch a new set of images
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
    
        
    }
    
    
    //MARK The repsone that calls update Map with student locations
    func handleGetFlickerPhotos(photos:FlickerResponse?, error:Error?) {
        
        
        guard let photos = photos else {
            print("Unable to Download photos from Flicker")
            print(error!)
            return
        }
        var pageNum: Int = (photos.photos?.pages)!
        print("Here is the page number \(pageNum)")
    
        
     self.getRandowPageNumber(pageNum: pageNum)
        
      
    }
    
    func getRandowPageNumber(pageNum: Int) {
        
        //Generate Random number to Narrow Scope
        let randPageNumber =  Int(arc4random_uniform(UInt32(pageNum) + 1))
        
              ParseFickrAPI.getPhotoLocationByPageNumber(url: EndPoints.getPhotos(randPageNumber, coordinates.latitude, coordinates.longitude).url, completionHandler: handleGetPhotoSearch(photos:error:))
    }
    
    //MARK: SEARCH FOR PHOTOS BY Getting AGE NUMBER TO NARROW PHOTO SEARCH
    func handleGetPhotoSearch(photos:FlickerResponse?, error:Error?) {
        
        
        guard let photos = photos else {
            print("Unable to Download photos from Flicker")
            print(error!)
            return
        }
        print("Photots \(photos.photos?.pages)")
        
        //MARK: SEARCH FOR PHOTOS BY Getting AGE NUMBER TO NARROW PHOTO SEARCH
        //lets get all the ids so we can grab photos
       photos.photos?.photo?.count
        
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flickrCell", for: indexPath)
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    

}


