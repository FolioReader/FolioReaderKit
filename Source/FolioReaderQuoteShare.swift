//
//  FolioReaderQuoteShare.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 8/11/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit


class FolioReaderQuoteShare: UIViewController {
    var quoteText: String!
    var filterImage: UIView!
    var imageView: UIImageView!
    var quoteLabel: UILabel!
    var titleLabel: UILabel!
    var authorLabel: UILabel!
    var logoImageView: UIImageView!
    var collectionView: UICollectionView!
    let collectionViewLayout = UICollectionViewFlowLayout()
    let itemSize: CGFloat = 90
    var dataSource = [QuoteImage]()
    let imagePicker = UIImagePickerController()
    var selectedIndex = 0
    
    // MARK: Init
    
    init(initWithText shareText: String) {
        super.init(nibName: nil, bundle: Bundle.frameworkBundle())
        self.quoteText = shareText.stripLineBreaks().stripHtml()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton()
        configureNavBar()
        
        let titleAttrs = [NSForegroundColorAttributeName: readerConfig.tintColor]
        let share = UIBarButtonItem(title: readerConfig.localizedShare, style: .plain, target: self, action: #selector(shareQuote(_:)))
        share.setTitleTextAttributes(titleAttrs, for: UIControlState())
        navigationItem.rightBarButtonItem = share
        
        //
        if isPad {
            preferredContentSize = CGSize(width: 400, height: 600)
        }
        let screenBounds = isPad ? preferredContentSize : UIScreen.main.bounds.size
        
        filterImage = UIView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.width))
        filterImage.backgroundColor = readerConfig.menuSeparatorColor
        view.addSubview(filterImage)
        
        imageView = UIImageView(frame: filterImage.bounds)
        filterImage.addSubview(imageView)
        
        quoteLabel = UILabel()
        quoteLabel.text = quoteText
        quoteLabel.textAlignment = .center
        quoteLabel.font = UIFont(name: "Andada-Regular", size: 26)
        quoteLabel.textColor = UIColor.white
        quoteLabel.numberOfLines = 0
        quoteLabel.baselineAdjustment = .alignCenters
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.adjustsFontSizeToFitWidth = true
        quoteLabel.minimumScaleFactor = 0.3
        quoteLabel.setContentCompressionResistancePriority(100, for: .vertical)
        filterImage.addSubview(quoteLabel)
        
        var bookTitle = ""
        var authorName = ""
        
        if let title = book.title() { bookTitle = title }
        if let author = book.metadata.creators.first { authorName = author.name }
        
        titleLabel = UILabel()
        titleLabel.text = bookTitle
        titleLabel.font = UIFont(name: "Lato-Bold", size: 15)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.setContentCompressionResistancePriority(600, for: .vertical)
        filterImage.addSubview(titleLabel)
        
        // Attributed author
        let attrs = [NSFontAttributeName: UIFont(name: "Lato-Italic", size: 15)!]
        let attributedString = NSMutableAttributedString(string:"\(readerConfig.localizedShareBy) ", attributes: attrs)
        
        let attrs1 = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
        let boldString = NSMutableAttributedString(string: authorName, attributes:attrs1)
        attributedString.append(boldString)
        
        authorLabel = UILabel()
        authorLabel.attributedText = attributedString
        authorLabel.textAlignment = .center
        authorLabel.textColor = UIColor.white
        authorLabel.numberOfLines = 1
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.adjustsFontSizeToFitWidth = true
        authorLabel.minimumScaleFactor = 0.5
        filterImage.addSubview(authorLabel)
        
        let logoImage = readerConfig.quoteCustomLogoImage
        let logoHeight = logoImage?.size.height ?? 0
        logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .center
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        filterImage.addSubview(logoImageView)
        
        // Configure layout contraints
        var constraints = [NSLayoutConstraint]()
        let views = [
            "quoteLabel": self.quoteLabel,
            "titleLabel": self.titleLabel,
            "authorLabel": self.authorLabel,
            "logoImageView": self.logoImageView
        ] as [String : Any]
        
        NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[quoteLabel]-20-[titleLabel]", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLabel]-0-[authorLabel]", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "V:[authorLabel]-25-[logoImageView(\(Int(logoHeight)))]-18-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[quoteLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[authorLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[logoImageView]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        filterImage.addConstraints(constraints)
        
        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionViewLayout.minimumLineSpacing = 15
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        
        let background = isNight(readerConfig.nightModeBackground, UIColor.white)
        view.backgroundColor = background
        
        // CollectionView
        let collectionFrame = CGRect(x: 0, y: filterImage.frame.height+15, width: screenBounds.width, height: itemSize)
        collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = background
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        view.addSubview(collectionView)
        
        if isPhone {
            collectionView.autoresizingMask = [.flexibleWidth]
        }
        
        // Register cell classes
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Create images
        dataSource = readerConfig.quoteCustomBackgrounds
        if readerConfig.quotePreserveDefaultBackgrounds {
            createDefaultImages()
        }
        
        // Picker delegate
        imagePicker.delegate = self
        
        // Select first item
        selectIndex(0)
    }
    
    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.white)
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }
    
    func createDefaultImages() {
        let color1 = QuoteImage(withColor: UIColor(rgba: "#FA7B67"))
        let color2 = QuoteImage(withColor: UIColor(rgba: "#78CAB6"))
        let color3 = QuoteImage(withColor: UIColor(rgba: "#71B630"))
        let color4 = QuoteImage(withColor: UIColor(rgba: "#4D5B49"))
        let color5 = QuoteImage(withColor: UIColor(rgba: "#959D92"), textColor: UIColor(rgba: "#4D5B49"))
        
        var gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#2989C9").cgColor, UIColor(rgba: "#21B8C2").cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        let gradient1 = QuoteImage(withGradient: gradient)
        
        gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#FAD961").cgColor, UIColor(rgba: "#F76B1C").cgColor]
        let gradient2 = QuoteImage(withGradient: gradient)
        
        gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#B4EC51").cgColor, UIColor(rgba: "#429321").cgColor]
        let gradient3 = QuoteImage(withGradient: gradient)
        
        dataSource.append(contentsOf: [color1, color2, color3, color4, color5, gradient1, gradient2, gradient3])
    }
    
    func selectIndex(_ index: Int) {
        let quoteImage = dataSource[index]
        let row = index+1
            
        filterImage.backgroundColor = quoteImage.backgroundColor
        imageView.alpha = quoteImage.alpha
        
        UIView.transition(with: filterImage, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.imageView.image = quoteImage.image
            self.quoteLabel.textColor = quoteImage.textColor
            self.titleLabel.textColor = quoteImage.textColor
            self.authorLabel.textColor = quoteImage.textColor
            self.logoImageView.image = self.logoImageView.image?.imageTintColor(quoteImage.textColor)
            }, completion: nil)
        
        //
        let prevSelectedIndex = selectedIndex
        selectedIndex = row
        
        guard prevSelectedIndex != selectedIndex else { return }
        
        collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: [
                IndexPath(item: self.selectedIndex, section: 0),
                IndexPath(item: prevSelectedIndex, section: 0)
            ])
        }, completion: nil)
    }
    
    // MARK: Share
    
    func shareQuote(_ sender: UIBarButtonItem) {
        var subject = readerConfig.localizedShareHighlightSubject
        var text = ""
        var bookTitle = ""
        var authorName = ""
        var shareItems = [AnyObject]()
        
        // Get book title
        if let title = book.title() {
            bookTitle = title
            subject += " “\(title)”"
        }
        
        // Get author name
        if let author = book.metadata.creators.first {
            authorName = author.name
        }
        
        text = "\(bookTitle) \n\(readerConfig.localizedShareBy) \(authorName)"
        
        let imageQuote = UIImage.imageWithView(filterImage)
        shareItems.append(imageQuote)
        
        if let bookShareLink = readerConfig.localizedShareWebLink {
            text += "\n\(bookShareLink.absoluteString)"
        }
        
        let act = FolioReaderSharingProvider(subject: subject, text: text)
        shareItems.insert(act, at: 0)
        
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToVimeo]
        
        // Pop style on iPad
        if let actv = activityViewController.popoverPresentationController {
            actv.barButtonItem = sender
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Status Bar
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return isNight(.lightContent, .default)
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
}

// MARK: UICollectionViewDataSource

extension FolioReaderQuoteShare: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let imageView: UIImageView!
        let tag = 9999
        
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        cell.contentView.layer.borderWidth = 1
        
        if let view = cell.contentView.viewWithTag(tag) as? UIImageView {
            imageView = view
        } else {
            imageView = UIImageView(frame: cell.bounds)
            imageView.tag = tag
            cell.contentView.addSubview(imageView)
        }
        
        // Image color
        let normalColor = UIColor(white: 0.5, alpha: 0.7)
        let camera = UIImage(readerImageNamed: "icon-camera")
        let dash = UIImage(readerImageNamed: "border-dashed-pattern")
        let cameraNormal = camera!.imageTintColor(normalColor)
        let dashNormal = dash!.imageTintColor(normalColor)
        
        // Camera
        guard (indexPath as NSIndexPath).row > 0 else {
            imageView.contentMode = .center
            imageView.image = cameraNormal
            cell.contentView.layer.borderColor = UIColor(patternImage: dashNormal).cgColor
            return cell
        }
        
        if selectedIndex == (indexPath as NSIndexPath).row {
            cell.contentView.layer.borderColor = readerConfig.tintColor.cgColor
            cell.contentView.layer.borderWidth = 3
        } else {
            cell.contentView.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).cgColor
        }
        
        let quoteImage = dataSource[(indexPath as NSIndexPath).row-1]
        imageView.image = quoteImage.image
        imageView.alpha = quoteImage.alpha
        imageView.contentMode = .scaleAspectFit
        cell.contentView.backgroundColor = quoteImage.backgroundColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemSize, height: itemSize)
    }
}

// MARK: UICollectionViewDelegate

extension FolioReaderQuoteShare: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard (indexPath as NSIndexPath).row > 0 else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let takePhoto = UIAlertAction(title: readerConfig.localizedTakePhoto, style: .default, handler: { (action) -> Void in
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            
            let existingPhoto = UIAlertAction(title: readerConfig.localizedChooseExisting, style: .default) { (action) -> Void in
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
            
            let cancel = UIAlertAction(title: readerConfig.localizedCancel, style: .cancel, handler: nil)
            
            alertController.addAction(takePhoto)
            alertController.addAction(existingPhoto)
            alertController.addAction(cancel)
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        selectIndex((indexPath as NSIndexPath).row-1)
    }
}

// MARK: ImagePicker delegate

extension FolioReaderQuoteShare: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {

            let quoteImage = QuoteImage(withImage: image, alpha: 0.6, backgroundColor: UIColor.black)

            collectionView.performBatchUpdates({
                self.dataSource.insert(quoteImage, at: 0)
                self.collectionView.insertItems(at: [IndexPath(item: 1, section: 0)])
                self.collectionView.reloadItems(at: [IndexPath(item: self.selectedIndex, section: 0)])
            }, completion: { (finished) in
                self.selectIndex(0)
            })
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}
