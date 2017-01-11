//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Xie kesong on 1/10/17.
//  Copyright © 2017 ___KesongXie___. All rights reserved.
//

import UIKit
import AFNetworking

let reuseIden = "MoviePosterCell"

fileprivate struct CollectionViewUI{
    static let UIEdgeSpace: CGFloat = 16.0
    static let MinmumLineSpace: CGFloat = 16.0
    static let MinmumInteritemSpace: CGFloat = 16.0
    static let cellCornerRadius: CGFloat = 4.0
}

class MoviesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var movieDict: [[String: Any]]?{
        didSet{
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        

        
        //network request
        self.activityIndicator.startAnimating()
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: FlickHttpRequest.nowPlayingURLString){
            let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
            urlSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if let data = data{
                    guard let responseJason = try? JSONSerialization.jsonObject(with: data, options: []) else{
                        print("Can't serialize data")
                        return 
                    }
                    if let responseDict = responseJason as? [String: Any]{
                        if let movieDictResult = responseDict[FlickHttpRequest.responseResultsKey] as? [[String: Any]]{
                            self.movieDict = movieDictResult
                        }
                    }
                }
            }).resume()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieDict?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIden, for: indexPath) as! MovieCollectionViewCell
        
        if let posterPath = self.movieDict![indexPath.row][FlickHttpRequest.posterPathKey] as? String{
            if let posterURL = URL(string: FlickHttpRequest.posterBaseUrl + posterPath){
                cell.moviePostImageView.setImageWith(posterURL)
            }
        }
        cell.layer.cornerRadius = CollectionViewUI.cellCornerRadius
        cell.layer.masksToBounds = true
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MoviesViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let posterLength = (self.view.frame.size.width - 2 * CollectionViewUI.UIEdgeSpace - CollectionViewUI.MinmumInteritemSpace) / 2 ;
        return CGSize(width: posterLength, height: posterLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionViewUI.MinmumLineSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake( CollectionViewUI.UIEdgeSpace,  CollectionViewUI.UIEdgeSpace,  CollectionViewUI.UIEdgeSpace,  CollectionViewUI.UIEdgeSpace)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return  CollectionViewUI.MinmumInteritemSpace
    }
}




