//
//  FolioReaderQuoteShare.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 8/11/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit


extension UIImage {
    static func gradientImageWithBounds(bounds: CGRect, colors: [CGColor], locations: [NSNumber] = [0.0, 1.0]) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension CALayer {
    
}

public struct QuoteImage {
    var image: UIImage?
    var gradient: CAGradientLayer?
    var color: UIColor?
    
    init(withImage image: UIImage) {
        self.image = image
    }
    
    init(withGradient gradient: CAGradientLayer) {
        self.gradient = gradient
    }
    
    init(withColor color: UIColor) {
        self.color = color
    }
}

class FolioReaderQuoteShare: UIViewController {
    var imageView: UIImageView!
    var collectionView: UICollectionView!
    let collectionViewLayout = UICollectionViewFlowLayout()
    let itemSize: CGFloat = 90
    var dataSource = [QuoteImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton()
        
        title = "Share"
        
        let screenBounds = UIScreen.mainScreen().bounds
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.width))
        imageView.backgroundColor = readerConfig.menuSeparatorColor
        view.addSubview(imageView)
        
        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionViewLayout.minimumLineSpacing = 15
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .Horizontal
        
        let background = isNight(readerConfig.nightModeBackground, UIColor.whiteColor())
        view.backgroundColor = background
        
        // CollectionView
        let collectionFrame = CGRect(x: 0, y: imageView.frame.height+15, width: screenBounds.width, height: itemSize)
        collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = background
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        view.addSubview(collectionView)
        
        // Register cell classes
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // 
        createDefaultImages()
    }
    
    func createDefaultImages() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#2989C9").CGColor, UIColor(rgba: "#21B8C2").CGColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        
        let image1 = QuoteImage(withColor: UIColor.redColor())
        let image2 = QuoteImage(withColor: UIColor.blueColor())
        let image3 = QuoteImage(withGradient: gradient)
        dataSource.appendContentsOf([image1, image2, image3])
    }
}

// MARK: UICollectionViewDataSource

extension FolioReaderQuoteShare: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let quoteImage = dataSource[indexPath.row]
        
        if let color = quoteImage.color {
            cell.backgroundColor = color
        }
        
        if let gradient = quoteImage.gradient {
            gradient.frame = cell.bounds
            cell.contentView.layer.insertSublayer(gradient, atIndex: 0)
        }
        
        if let image = quoteImage.image {
            let imageView = UIImageView(frame: cell.bounds)
            imageView.image = image
            cell.contentView.addSubview(imageView)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: itemSize, height: itemSize)
    }
}

// MARK: UICollectionViewDelegate

extension FolioReaderQuoteShare: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.item)
    }
}