//
//  DetailViewController.swift
//  EQM
//
//  Created by Nahum Jovan Aranda López on 11/03/16.
//  Copyright © 2016 Nahum Jovan Aranda López. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class DetailViewController: UIViewController {
    var viewModel: DetailViewViewModel! {
        didSet {
            self.view.backgroundColor = viewModel?.color ?? UIColor.whiteColor()
            self.depthLabel.text = viewModel?.depth
            self.timeLabel.text = viewModel?.time
            self.dateLabel.text = viewModel?.date
            self.magnitudeLabel.text = viewModel?.magnitude
            self.placeLabel.text = viewModel?.place
            
            if let coordinate = viewModel?.coordinate {
                let annotation = QuakeAnnotation(coordinate: coordinate , title: viewModel?.place, subtitle: viewModel?.magnitudeDescription, color: viewModel?.color)
                self.mapView.addAnnotation(annotation)
                self.setupMapView(coordinate)
            }
        }
    }
    
    let dataManager = DataManager()
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var magnitudeLabel: UILabel!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet var dataContainers: [UIView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        for container in self.dataContainers {
            container.layer.borderColor = UIColor.darkGrayColor().CGColor
            container.layer.borderWidth = 1.0
            container.layer.cornerRadius = 5.0
            container.layer.masksToBounds = true
        }
        
        infoContainer.layer.borderColor = UIColor.darkGrayColor().CGColor
        infoContainer.layer.borderWidth = 1.0
        infoContainer.layer.cornerRadius = 5.0
        infoContainer.layer.masksToBounds = true

        mapView.layer.borderColor = UIColor.darkGrayColor().CGColor
        mapView.layer.borderWidth = 1.0
        mapView.layer.cornerRadius = 5.0
        mapView.layer.masksToBounds = true
    }
    
    private func setupMapView(coordinate: CLLocationCoordinate2D) {
        mapView.setCenterCoordinate(coordinate, animated: false)
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegionMake(coordinate, span)
        
        mapView.setRegion(region, animated: false)
    }
}

extension DetailViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                //return nil so map view draws "blue dot" for standard user location
                return nil
            }
            
            let reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.animatesDrop = true
                pinView!.pinTintColor = (annotation as? QuakeAnnotation)?.color
            }
            else {
                pinView!.annotation = annotation
            }
            
            return pinView
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        if let annotation = mapView.annotations.last {
            mapView.selectAnnotation(annotation, animated: false)
        }
    }
}