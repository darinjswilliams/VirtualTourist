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
    let mininumRange = 1
    let maximumRange = 15
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayOut: UICollectionViewFlowLayout!
    @IBOutlet weak var labelNoPhotos: UILabel!
    @IBOutlet weak var newPhotosButton: UIBarButtonItem!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    //tear down NSfetchResultsController
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    //MARK: retrieve saved images from core data, else call flicker and get new photoz
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        let space:CGFloat = 8
        let dimension = (view.frame.size.width - (2 * space)) / 4.0
        let hdimention = (view.frame.size.height - (2 * space)) / 4.0
        flowLayOut.minimumInteritemSpacing = space
        flowLayOut.minimumLineSpacing = space
        flowLayOut.itemSize = CGSize(width: dimension, height: hdimention)
        print("here is frame width \(view.frame.size.width)")
        print("here is frame dimension \(view.frame.size.height)")
        
        
        //adjust flow layout
//        flowLayOut.minimumInteritemSpacing = 0.2
//        flowLayOut.minimumLineSpacing = 0.2
//        flowLayOut.itemSize = CGSize(width: 135, height: 135)
        
        //MARK if phots are in pin retrieve from GCD
        photoCount = (pin.pin?.count)!
        print("Photo View Controller count from GCD... \(photoCount)")
        
        
        self.newPhotosButton.isEnabled = false
       
        //MARK IF GCD HAS PHOTOS FROM PREVIOUS PIN DISPLAY PHOTOS
        if photoCount > 0 {
            
            let gcdPhotoObjects = pin.pin?.allObjects
            
            for photoFromGCD in gcdPhotoObjects! {
                 let  storedPhoto = photoFromGCD as! Photo
                 let image = UIImage(data: storedPhoto.flickrImages as! Data)
                 photosImage.append(image!)
            }
      self.collectionView.reloadData()
      self.newPhotosButton.isEnabled = true
            
        } else {
        
         callParseFlickrApi()
        }
        
        initializeMapView()
    }
    
    
    
    //MARK SET UP MAP VIEW AND COLLECTION RELOAD
    func  initializeMapView() {
        
     
        
        collectionView?.reloadData()
        collectionView?.allowsMultipleSelection = true;
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinates!
        annotation.title = "Coordinates Found"
        
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coordinates!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK Tapping this button should empty the photo album and fetch a new set of images
    @IBAction func newCollectionButtonPressed(_ sender: Any) {
    
        photoCount = 0

         self.newPhotosButton.isEnabled = false
        
        //MARK EMPTY THE PHOTO ALBUM
        photosImage = [UIImage]()
        let photoSet = pin?.pin
        
        //MARK DELETE ALL PHOTOS FROM GCD
        print("PHOTOS IN PHOTOTSET \(String(describing: photoSet?.count))")
        for photo in photoSet! {
            dataController.viewContext.delete(photo as! NSManagedObject)
        }
        
        collectionView.reloadData()
        callParseFlickrApi()
        initializeMapView()
        
    }
    
    
    func callParseFlickrApi () {
        
           ParseFickrAPI.processPhotos(url: EndPoints.getAuthentication(coordinates.latitude, coordinates.longitude).url, completionHandler: self.handleGetFlickerPhotos(photos:error:))
    }
    
    
    //MARK The repsone that calls update Map with student locations
    func handleGetFlickerPhotos(photos:FlickerResponse?, error:Error?) {
        
        guard let photos = photos else {
            print("Unable to Download photos from Flicker")
            self.labelNoPhotos.text = "No Photos"
            
            return
        }
        
      
        //Lets get the pages for photos object
        let totalPages: Int = (photos.photos.pages)
        
        
        if totalPages <= 0 {
            self.labelNoPhotos.text = "No Photos"
            return
        } else {
        
        
        print("Here is the page number \(totalPages)")
      
    
        
     self.getRandowPageNumber(totalPages: totalPages)
        }
      
    }
    
    func getRandowPageNumber(totalPages: Int) {
        
        //MARK -  lets generate random number between RANGE
        let randomPageNumber = Int.random(in: mininumRange...totalPages)
        
        print("Here is the random number generated \(randomPageNumber)")
        
        
        ParseFickrAPI.getPhotoLocationByPageNumber(url: EndPoints.getPhotos(randomPageNumber, coordinates.latitude, coordinates.longitude).url, completionHandler: self.handleGetPhotoSearch(photos:error:))
    }
    
    //MARK: SEARCH FOR PHOTOS BY Getting PAGE NUMBER TO NARROW PHOTO SEARCH
    func handleGetPhotoSearch(photos:FlickerResponse?, error:Error?) {
        
        
        guard let photos = photos else {
            showAlert("Photo Search", message: "Unable to Download photos from Flicker")
            print("Unable to Download photos from Flicker")
            print(error!)
            return
        }
    
        //MARK: SEARCH FOR PHOTOS BY Getting PAGE NUMBER TO NARROW PHOTO SEARCH
        print("Photos Count \( photos.photos.photo.count )")
        
        if photos.photos.photo.count <= 0  {
            
            print("NO PHOTOS AT THIS SITE \(photos.photos.photo.count)")
            self.labelNoPhotos.text = "No Images"
            
            return
        }
        
        self.getImageByIdAndDownload(photos: photos)
        
    
    }
    
    
    
    func getImageByIdAndDownload(photos:FlickerResponse){
        
        
        //MARK LIMIT PHOTOS TO 12Y
        for i in self.mininumRange...self.maximumRange {

            let farm: Int = photos.photos.photo[i].farm
            let serverID: String = photos.photos.photo[i].server
            let id: String = photos.photos.photo[i].id
            let secret: String = photos.photos.photo[i].secret
            
           let imageUrl = EndPoints.getImageUrl(farm, serverID, id, secret).url
            print(imageUrl)
            
            
            ParseFickrAPI.taskDownLoadPhotosData(url: imageUrl, completionHandler: self.handleDownLoadPhotos(photos:error:))

           }
        
    }
    
    
    
    func handleDownLoadPhotos(photos:UIImage?, error:Error?){
        
        guard let photos = photos else {
            //TODO REPLACE WITH SHOW ERROR FUNCTION
            showAlert("Photos Download", message: "No Photos Download")
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
            let photoOfImage = Photo(context: self.dataController.viewContext)

            //Assign Image Data to GCD Photo in PNG Format
                photoOfImage.flickrImages = (photos.pngData() as Data?)


            //Add Photo to GCD Pin
            self.pin.addToPin(photoOfImage)
            print("Adding photo to GCD pin \(photoOfImage)")


            //Save GCD Context
            try self.dataController.viewContext.save()

            print("The is ping count \(self.pin?.pin?.count ?? 0)")

           let imagePath = IndexPath(item: self.photosImage.count - 1, section: 0)

                print("Here is the Image Index \(imagePath)")
                // RELOAD COLLECTION VIEW IMAGE ONE ITEM AT A TIME
                self.collectionView.reloadItems(at: [imagePath])
 
                
              //Check Count and Enable B == utton
                if self.photosImage.count == self.pin.pin?.count {
                
                    self.newPhotosButton.isEnabled = true
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
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
    
    
    //MARK DELETE PHOTO FROM GCD IF TOUCHED
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        self.photoCount -= 1
        print("The photoCount now is \(self.photoCount)")
        self.photosImage.remove(at: indexPath.item)
        self.collectionView.deleteItems(at: [indexPath])
        
        // Remove from DB
        let photoObjs = self.pin?.pin?.allObjects
        let photoObj = photoObjs?[indexPath.item] as? Photo
        
        do {
            dataController.viewContext.delete(photoObj!)
            try dataController.viewContext.save()
        }
        catch let error
        {
            print(error)
        }
        
        return
       
    }
    
    
    //MARK Render  each pin's
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
    
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
            return
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }
        
}


