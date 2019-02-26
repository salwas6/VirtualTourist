//
//  MapVC.swift
//  VirtualTourist
//
//  Created by Salwa Tanko on 1/19/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var annotations = [MKPointAnnotation]()
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.count != 0 {
                let Pin = fetchedResultsController.fetchedObjects
                annotations.removeAll()
                
                for pin in Pin! {
                    
                    let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    annotations.append(annotation)
                    self.mapView.addAnnotation(annotation)
                }
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotations(annotations)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AddPin(longGesture:)))
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func AddPin(longGesture: UIGestureRecognizer) {
        
        if longGesture.state == .began {
            let touchPoint = longGesture.location(in: mapView)
            let coords = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = Double(coords.latitude)
            pin.longitude = Double(coords.longitude)
            try? dataController.viewContext.save()
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coords
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func addPin(annotation : MKPointAnnotation){
        DispatchQueue.main.async {
            let pin = Pin(context: self.dataController.viewContext)
            pin.latitude = annotation.coordinate.latitude
            pin.longitude = annotation.coordinate.longitude
            pin.createdDate = Date()
        }
        try? self.dataController.viewContext.save()
    }
    
    func findPins(annotation: CLLocationCoordinate2D) -> Pin? {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", annotation.latitude, annotation.longitude)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let pin = try? dataController.viewContext.fetch(fetchRequest).first
        
        return pin!
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        API.fetchPhotos(annotation: view.annotation as! MKPointAnnotation){ (error) in
            if(error == nil){
                DispatchQueue.main.async {
                    
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumVC
                    controller.annotation = view.annotation as! MKPointAnnotation
                    controller.dataController = self.dataController
                    
                    controller.selctedPin = self.findPins(annotation: (view.annotation?.coordinate)!)
                    self.navigationController!.pushViewController(controller, animated: true)
                }
            }
            else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}



