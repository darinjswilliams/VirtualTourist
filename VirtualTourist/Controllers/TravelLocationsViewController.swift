//
//  TravelLocationsViewController.swift
//  VirtualTourist
//
//  Created by Darin Williams on 5/15/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationsViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    var mapAnnotations = [MKAnnotation]()
    var travelCoordinates : CLLocationCoordinate2D?
    var dataController:DataController!
    var coordS: String = ""
    var pin: Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //tear down fetch result contoller
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated )
        // fetch and add to map
   
        
    }

    //MARK - USE GESTURE LONG PRESSED, IF PIN IS TAP TRANSITION TO  PHOTO ALBUM
    @IBAction func pinPressed(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: mapView)
    
        
        travelCoordinates = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = travelCoordinates!
        
        let long = travelCoordinates?.longitude
        let lat = travelCoordinates?.latitude
        
        
        annotation.title = String(lat!)+String(long!)
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: travelCoordinates!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        savePinLocationToCoreData(longitude: long!, latitude: lat!)
        
    }
    
    func savePinLocationToCoreData(longitude: CLLocationDegrees, latitude: CLLocationDegrees){
        
        do{
            let pin = Pin(context: dataController.viewContext)
            pin.latitude  = latitude
            pin.longitude  = longitude
            coordS = String(latitude)+String(longitude)
            pin.coordinates = coordS
            
            //MARK: When pins are dropped on the map, the pins are persisted as Pin instances in Core Data and the context is saved.
            try dataController.viewContext.save()
            print("done")
        }
        catch let error
        {
            print(error)
        }
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
    
    
    
    //MARK: when pin is touch  transition to photo album
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //Get current Coordinates
        travelCoordinates = view.annotation?.coordinate
        
        //Set coordinates to search for on map
        coordS = (view.annotation?.title!)!
        
        //fetch current location data
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        
        //Use predicate to search
        fetchRequest.predicate = NSPredicate(format: "coordinates == %@",coordS)
        if let result = try?  dataController.viewContext.fetch(fetchRequest)
        {
            if(result.count > 0)
            {
                pin = result[0]
            }
            else
            {
                return
            }
        }
        
        
        self.performSegue(withIdentifier: "showPhotos", sender: self)
        
    }
    
    
    //MARK: All Controller inherit prepare, which is called before performSeque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let controllerViewDest = segue.destination as?  PhotoAlbumViewController else {
            showFailure(message: "Please re-check pin location")
            return
        }
        
        controllerViewDest.coordinates = self.travelCoordinates
        controllerViewDest.pin = self.pin
        controllerViewDest.dataController = self.dataController
        

        
    }
}
