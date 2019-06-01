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
        
        //TODO; CALL FLICKER GET PHOTOS PLACE IF STATEMENT TO GET GCD 
         callParseFlickrApi()
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK Tapping this button should empty the photo album and fetch a new set of images
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
    
        
    }
    
    
    func callParseFlickrApi () {
        
           ParseFickrAPI.processPhotos(url: EndPoints.getAuthentication(coordinates.latitude, coordinates.longitude).url, completionHandler: handleGetFlickerPhotos(photos:error:))
        
    }
    
    
    //MARK The repsone that calls update Map with student locations
    func handleGetFlickerPhotos(photos:FlickerResponse?, error:Error?) {
        
        
        guard let photos = photos else {
            print("Unable to Download photos from Flicker")
            print(error!)
            return
        }
        
        //Lets get the pages for photos object
        let pageNum: Int = (photos.photos.pages)
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
        print("Photots \(photos.photos.pages)")
    
        
        //MARK: SEARCH FOR PHOTOS BY Getting AGE NUMBER TO NARROW PHOTO SEARCH
        //lets get all the ids so we can grab photos
        print("Photos Count \( photos.photos.photo.count )")
        self.getImageByIdAndDownload(photos: photos)
        
    
    }
    
    
    func getImageByIdAndDownload(photos:FlickerResponse){
    

        //MARK LIMIT PHOTOS TO 12
       
        for i in 1 ... 12 {
            
        print("\(photos.photos.photo[i].id), \(photos.photos.photo[i].secret), \(photos.photos.photo[i].farm), \(photos.photos.photo[i].server)")
            
            let farm: Int = photos.photos.photo[i].farm
            let serverID: String = photos.photos.photo[i].server
            let id: String = photos.photos.photo[i].id
            let secret: String = photos.photos.photo[i].secret
            
            let imageUrl = EndPoints.getImageUrl(farm, serverID, id, secret).url
            print(imageUrl)
            
            //Download Content of Photos
            let downloadImage = try! UIImage(data: Data(contentsOf: imageUrl))
            
            
            //Store content of Photos
            self.photosImage.append(downloadImage!)
            //TODO CALL DispatchQueue to update main
            DispatchQueue.main.sync {
                do {
                    
                    //GCD: Get Context
                    let photoOfImage = Photo(context: self.dataController.viewContext)
                
                    //lets download the image
                    photoOfImage.flickrImages = downloadImage!.pngData() as Data?
                    
                    //Add to GCD
                    self.pin.addToPin(photoOfImage)
                   
                } catch let error {
                    
                }
      }
    }
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


