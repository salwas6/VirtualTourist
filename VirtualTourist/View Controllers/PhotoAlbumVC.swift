//
//  CollectionVC.swift
//  VirtualTourist
//
//  Created by Salwa Tanko on 1/19/19.
//  Copyright © 2019 Udacity. All rights reserved.
//
import UIKit
import MapKit
import CoreData
import Kingfisher

class PhotoAlbumVC: UIViewController, MKMapViewDelegate, UICollectionViewDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photosCollection: UICollectionView!
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    var appDelegate: AppDelegate!
    var dataController:DataController!
    var selctedPin: Pin!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var annotation = MKPointAnnotation()
    
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", selctedPin)
        let sortDescriptor = NSSortDescriptor(key: "createdDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(annotation)-notes")
        fetchedResultsController.delegate = self as! NSFetchedResultsControllerDelegate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionViewLayout()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let region = MKCoordinateRegion(center: self.annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        
        var annotations = [MKPointAnnotation]()
        annotations.append(self.annotation)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
        
        setupFetchedResultsController()
        if fetchedResultsController.fetchedObjects!.count == 0 {
            loadPhoto()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadPhoto() {
        DispatchQueue.main.async {
            for index in 0 ..< Photos.photos.count  {
                
                let imageUrlString = Photos.photos[index]
                
                let picture = Photo(context: self.dataController.viewContext)
                picture.url = imageUrlString
                picture.createdDate = Date()
                picture.pin = self.selctedPin
            }
            
            if Photos.photos.count == 0 {
                let alertController = UIAlertController(title: "...", message: "No photos to load in this area", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            try? self.dataController.viewContext.save()
        }
    }
    

    @IBAction func newCollectionClicked(_ sender: Any) {
       
        print("new collection")
        API.fetchPhotos(annotation: self.annotation){ (error) in
            
            if error != nil {
                print("Error")
            }
            else {
                DispatchQueue.main.async {
                    self.newPhotoCollection()
                    self.loadPhoto()
                    self.photosCollection.reloadData()
                }
            }
        }
    }
    
    func newPhotoCollection(){
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.includesPropertyValues = false
        do {
            let results = try self.dataController.viewContext.fetch(fetchRequest) as [NSManagedObject]
            results.forEach(){
                result in dataController.viewContext.delete(result)
                try? dataController.viewContext.save()
            }
        } catch {
            print("Error")
        }
    }
    
    func downloadImage(url:URL, completion: @escaping (_ data: Data?,_ error: Error?) -> Void){
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if error == nil {
                if let data = data {
                    completion(data,nil)
                }
                
            }else {
                completion(nil,error)
            }
        }
        dataTask.resume()
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
}

extension PhotoAlbumVC:NSFetchedResultsControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let delPic = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(delPic)
        try? dataController.viewContext.save()
        setupFetchedResultsController()
        self.photosCollection.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCell
        let imageUrlString = photo.url
        let url = URL(string: imageUrlString!)
        //cell.ImageView.kf.setImage(with: url)
        cell.ImageView.image = UIImage(named: "placeholder")
        cell.activityIndicator.startAnimating()
        if let data = photo.imageData {
            cell.ImageView.image =  UIImage(data: data)
            cell.activityIndicator.stopAnimating()
             cell.activityIndicator.hidesWhenStopped = true
        } else {
            downloadImage(url: url! ) { (data, error) in
                if error != nil {
                    print("Error")
                    cell.activityIndicator.stopAnimating()
                } else{
                    cell.ImageView.image =  UIImage(data: data! )
                    photo.imageData = data
                    try? self.dataController.viewContext.save()
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.hidesWhenStopped = true
                }
            }
        }
        return cell
    }
    /*
    
    */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        photosCollection.reloadData()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func setCollectionViewLayout() {
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = space
        layout.minimumLineSpacing = space
        layout.itemSize = CGSize(width: dimension, height: dimension)
        
       photosCollection.setCollectionViewLayout(layout, animated: true)
    }
}
