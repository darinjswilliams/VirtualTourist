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
//        print(coordinates.latitude)
//         print(coordinates.longitude)
//        print(pin)
//        print(dataController)
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        let hdimention = (view.frame.size.height - (2 * space)) / 3.0
        flowLayOut.minimumInteritemSpacing = space
        flowLayOut.minimumLineSpacing = space
        flowLayOut.itemSize = CGSize(width: dimension, height: hdimention)
    }

    //tear down NSfetchResultsController
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
 
        
    }
    
    //MARK: retrieve saved images from core data, else call flicker and get new photoz
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //adjust flow layout
        flowLayOut.minimumInteritemSpacing = 1
        flowLayOut.minimumLineSpacing = 1
        flowLayOut.itemSize = CGSize(width: 135, height: 135)
        
        //TODO; CALL FLICKER GET PHOTOS PLACE IF STATEMENT TO GET GCD
        photoCount = (pin.pin?.count)!
        print("Photo View Controller count from GCD... \(photoCount)")
        
        if photoCount > 0 {
            
            let gcdPhotoObjects = pin.pin?.allObjects
            
            for photoFromGCD in gcdPhotoObjects! {
                 let  storedPhoto = photoFromGCD as! Photo
                 let image = UIImage(data: storedPhoto.flickrImages as! Data)
                 photosImage.append(image!)
            }
        } else {
        
         callParseFlickrApi()
         initializeMapView()
            
        }
    }
    
    
    
    //MARK SET UP MAP VIEW AND COLLECTION RELOAD
    func  initializeMapView() {
        
        
        collectionView?.reloadData()
        collectionView?.allowsMultipleSelection = true;
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinates!
//        annotation.title = name
        
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinates!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
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
    
    //MARK: SEARCH FOR PHOTOS BY Getting PAGE NUMBER TO NARROW PHOTO SEARCH
    func handleGetPhotoSearch(photos:FlickerResponse?, error:Error?) {
        
        
        guard let photos = photos else {
            print("Unable to Download photos from Flicker")
            print(error!)
            return
        }
        print("Photots \(photos.photos.pages)")
    
        
        //MARK: SEARCH FOR PHOTOS BY Getting PAGE NUMBER TO NARROW PHOTO SEARCH
        //lets get all the ids so we can grab photos
        print("Photos Count \( photos.photos.photo.count )")
        
        if photos.photos.photo.count <= 0  {
            
            print("NO PHOTOS AT THIS SITE \(photos.photos.photo.count)")
            
            return
        }
        
        self.getImageByIdAndDownload(photos: photos)
        
    
    }
    
    func handleDownLoadPhotos(photos:UIImage?){
        
        guard let photos = photos else {
            //TODO REPLACE WITH SHOW ERROR FUNCTION
            print("Photo Error no Data")
            return
        }
        
     
        
        
        //Update Image on Main Thread
        DispatchQueue.main.async {
            do {
                //Append  images to Array
                self.photosImage.append(photos)
                print(photos)
                self.collectionView.reloadData()
                
            //GCD: Get Context
//            let photoOfImage = Photo(context: self.dataController.viewContext)
//
//            //Assign Image Data to GCD Photo in PNG Format
//                photoOfImage.flickrImages = (photos.pngData() as Data?)
//
//
//            //Add Photo to GCD Pin
//            self.pin.addToPin(photoOfImage)
//
//
//            //Save GCD Context
//            try self.dataController.viewContext.save()
//
//            print("The is ping count \(self.pin?.pin?.count ?? 0)")
//
//           let imagePath = IndexPath(item: self.photosImage.count - 1, section: 0)
//
//                print("Here is the Image Index \(imagePath)")
//                //TODO RELOAD COLLECTIN VIEW
//                self.collectionView.reloadItems(at: [imagePath])
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func getImageByIdAndDownload(photos:FlickerResponse){
    

        //MARK LIMIT PHOTOS TO 12
       
        for i in 1 ... 12 {
            
//        print("\(photos.photos.photo[i].id), \(photos.photos.photo[i].secret), \(photos.photos.photo[i].farm), \(photos.photos.photo[i].server)")
            
            let farm: Int = photos.photos.photo[i].farm
            let serverID: String = photos.photos.photo[i].server
            let id: String = photos.photos.photo[i].id
            let secret: String = photos.photos.photo[i].secret
            
            let imageUrl = EndPoints.getImageUrl(farm, serverID, id, secret).url
            print(imageUrl)
            
            
          //Call FlckerAPI to download Image Data
            ParseFickrAPI.downLoadPhotos(url: EndPoints.getImageUrl(farm, serverID, id, secret).url, completionHandler: handleDownLoadPhotos(photos:))
            
            
    }
        
        //TODO ENABLE BUTTON
}

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("CollectionView photo count \(self.photosImage.count)")
        return self.photosImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrCollectionViewCell", for: indexPath) as! FlickrCollectionViewCell
        
       
        // Render as bit map before rendering
        cell.layer.shouldRasterize = true
        
        // Scale the raster content to size of  main screen
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.015)
        
        DispatchQueue.main.async {
            if self.photosImage.count >= indexPath.item + 1 {
               cell.photoCell.image = self.photosImage[indexPath.item]
            } else {
                cell.photoCell.image = nil
            }
        }
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    
    
    // each pin's rendering
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .blue
            pinView?.rightCalloutAccessoryView = UIButton(type:.detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    
        
}


