//
//  Utilities.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import Foundation
import JCAlertView
import NVActivityIndicatorView
import CoreData

struct Utilities {
    
    
    static let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static let session = NSURLSession.sharedSession()
    static let userDefault = NSUserDefaults.standardUserDefaults()
    static let screenSize = UIScreen.mainScreen().bounds.size
    
    
    //MARK: Networking Methods
    static func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    //MARK: AlertViewType
    enum AlertViewType {
        case AlertViewWithOneButton
        case AlertViewWithTwoButtons
    }
    
    //CoreData
    static func objectSavedInCoreData(id: Int, entity: String) -> AnyObject? {
        let fetchRequest = NSFetchRequest(entityName: entity)
        let predicate = NSPredicate(format: "id = %d", id)
        fetchRequest.predicate = predicate
        do {
            let result = try Utilities.appDelegate.stack.context.executeFetchRequest(fetchRequest)
            return result.first
        } catch {
            return nil
        }
    }
    
    static func createNewMovie(movie: TMDBMovie) -> Movie {
        let id = movie.id
        let title = movie.title
        var posterPath: NSURL? = nil
        if let path = movie.posterPath {
            posterPath = TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.RowPoster, filePath: path)
        }
        let overview = movie.overview
        let voteAverage = movie.voteAverage
        let voteCount = movie.voteCount
        let runtime = movie.runtime
        let popularity = movie.popularity
        let releaseDate = movie.releaseYear
        
        let newMovie = Movie(id: id, title: title, posterPath: posterPath, overview: overview, voteAverage: voteAverage, voteCount: voteCount, runtime: runtime, releaseDate: releaseDate, popularity: popularity, context: Utilities.appDelegate.stack.context)
        print("New Movie Created!")
        
        // Create Collection From Movie Details
        if let collectionData = movie.belongsToCollection {
            let collection = TMDBCollection.init(dictionary: collectionData)
            if let savedCollection = Utilities.objectSavedInCoreData(collection.id, entity: CoreDataEntityNames.Collection) as? Collection {
                savedCollection.addMoviesObject(newMovie)
            } else {
                let newCollection = createNewCollection(collection)
                newCollection.addMoviesObject(newMovie)
            }
        }
        return newMovie
    }
    
    static func createNewCollection(collection: TMDBCollection) -> Collection {
        let name = collection.name
        let id = collection.id
        var backdropPath: NSURL? = nil
        if let path = collection.backdropPath {
            backdropPath = TMDBClient.sharedInstance.createUrlForImages(TMDBClient.BackdropSizes.DetailBackdrop, filePath: path)
        }
        let newCollection = Collection(name: name, id: id, backdropPath: backdropPath, context: Utilities.appDelegate.stack.context)
        print("New Collection Created!")
        return newCollection
    }
}


//MARK: GCD block
func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

//MARK: AlertView
func showAlertViewWith(title: String, error: String, type: Utilities.AlertViewType, firstButtonTitle: String?, firstButtonHandler: (() -> Void)?, secondButtonTitle: String?, secondButtonHandler: (() -> Void)? ) {
    switch type {
    case .AlertViewWithOneButton:
        JCAlertView.showOneButtonWithTitle(title, message: error, buttonType: .Default, buttonTitle: firstButtonTitle, click: firstButtonHandler)
        break
    case .AlertViewWithTwoButtons:
        JCAlertView.showTwoButtonsWithTitle(title, message: error, buttonType: .Default, buttonTitle: firstButtonTitle, click: firstButtonHandler, buttonType: .Cancel, buttonTitle: secondButtonTitle, click: secondButtonHandler)
        break
    }
}



//MARK: ActivityIndeicator View
extension NVActivityIndicatorView {
    class func showHUDAddedTo(view: UIView) {
        let hud = NVActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100), type: .BallSpinFadeLoader, color: UIColor.grayColor(), padding: 20)
        hud.center = view.center
        hud.hidesWhenStopped = true
        view.addSubview(hud)
        hud.startAnimation()
    }
    
    class func hideHUDForView(view: UIView) {
        if let hud = HUDForView(view) {
            hud.hidesWhenStopped = true
            hud.stopAnimation()
            hud.removeFromSuperview()
        }
    }
    
    private class func HUDForView(view: UIView) -> NVActivityIndicatorView? {
        let subviewEnum = view.subviews.reverse()
        for subview in subviewEnum {
            if subview.isKindOfClass(self) {
                return subview as? NVActivityIndicatorView
            }
        }
        return nil
    }
}

//MARK: String Helper Methods
extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.max)
        
        let boundingBox = self.boundingRectWithSize(constraintRect, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
