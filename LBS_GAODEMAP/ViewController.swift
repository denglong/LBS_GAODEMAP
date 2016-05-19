//
//  ViewController.swift
//  LBS_GAODEMAP
//
//  Created by denglong on 5/19/16.
//  Copyright © 2016 邓龙. All rights reserved.
//

import UIKit

let APIKey = "e85d1153ddd0c5affa8d60ac5d3f1ad8"
let screen_bounds = UIScreen.mainScreen().bounds

class ViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MAMapView!
    @IBOutlet weak var mapTableView: UITableView!
    var search:AMapSearchAPI?
    var poi:AMapPOI!
    var currentLocation:CLLocation?
    var poiList:Array<AnyObject>! = []
    var islocation:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMapView()
        initSearch()
        registerTableViewCellAction()
    }
    
    func registerTableViewCellAction() {
        mapTableView.hidden = true
        let footView = UIView()
        mapTableView.tableFooterView = footView
        
        mapTableView.estimatedRowHeight = screen_bounds.height
        mapTableView.rowHeight = UITableViewAutomaticDimension
        
        mapTableView.registerNib(UINib(nibName: "MapDetailCell", bundle: nil), forCellReuseIdentifier: "MapDetailCell")
    }

    //MARK - 初始化MAMapView
    func initMapView(){
        mapView!.delegate = self
        mapView!.showsUserLocation = true
        //mapView!.customizeUserLocationAccuracyCircleRepresentation = true
        mapView!.setUserTrackingMode(MAUserTrackingMode.Follow, animated: true)
    }
    
    //MARK - 初始化AMapSearch
    func initSearch() {
        AMapSearchServices.sharedServices().apiKey = APIKey
        search = AMapSearchAPI()
        search!.delegate = self
    }
    
    //MARK - POI周边搜索
    func searchReGeocodeWithCoordinate(coordinate: CLLocationCoordinate2D!) {
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.locationWithLatitude(CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        request.types = "学校|写字楼|小区|街道|医院|公园"
        request.sortrule = 0
        request.requireExtension = true
        search?.AMapPOIAroundSearch(request)
    }
    
    //MARK:- MAMapViewDelegate
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if islocation {
            islocation = false
            mapView!.setUserTrackingMode(MAUserTrackingMode.None, animated: true)
            searchReGeocodeWithCoordinate(userLocation.coordinate)
            
            //设置地图显示比例
            let span = MACoordinateSpanMake(0.005, 0.005)
            let region = MACoordinateRegionMake(userLocation.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func mapView(mapView: MAMapView!, regionDidChangeAnimated animated: Bool) {
        searchReGeocodeWithCoordinate(mapView.centerCoordinate)
    }
    
    func mapView(mapView: MAMapView, viewForAnnotation annotation: MAAnnotation) -> MAAnnotationView? {
        
        if annotation.isKindOfClass(MAPointAnnotation) {
            let annotationIdentifier = "invertGeoIdentifier"
            
            var poiAnnotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIdentifier) as? MAPinAnnotationView
            
            if poiAnnotationView == nil {
                poiAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            poiAnnotationView!.pinColor = MAPinAnnotationColor.Green
            poiAnnotationView!.animatesDrop   = true
            poiAnnotationView!.canShowCallout = true
            
            return poiAnnotationView;
        }
        return nil
    }
    
    //MARK:- AMapSearchDelegate
    func AMapSearchRequest(request: AnyObject!, didFailWithError error: NSError!) {
        print("request :\(request), error: \(error)")
    }
    
    func onPOISearchDone(request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.pois.count == 0
        {
            mapTableView.hidden = true
            return;
        }
        poiList = []
        poiList = response.pois
        mapTableView.hidden = false
        mapTableView.reloadData()
    }
    
    //MARK - TableViewDelegate,TableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MapDetailCell") as! MapDetailCell
        poi = poiList[indexPath.row] as! AMapPOI
        cell.addressName.text = poi.name
        cell.addressDetail.text = poi.city + poi.district + poi.address
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    //MARK - 回到定位点
    @IBAction func comeBackPointAction(sender: UIButton) {
        mapView?.centerCoordinate = (mapView?.userLocation.coordinate)!
    }
}

