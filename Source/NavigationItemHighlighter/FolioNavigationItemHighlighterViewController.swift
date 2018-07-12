//
//  HoleTutorialViewController.swift
//  SberbankVS
//
//  Created by Dmitry Rozov on 05/07/2018.
//  Copyright © 2018 Mobile Up. All rights reserved.
//

import UIKit

let highlightRadiusLength: CGFloat = 35

@available(iOS 9, *)
internal class FolioNavigationItemHighlighterViewController: UIViewController {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 21, weight: .bold)
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    let button: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 24
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(red: 0.22, green: 0.60, blue: 0.33, alpha: 1)
        return button
    }()
    let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private var maskView: UIView!
    private var content: [FolioNavigationItemHighlighterContent]!
    private var currentContentIndex: Int = 0 {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                self.titleLabel.alpha = 0
                self.descriptionLabel.alpha = 0
            }) { _ in
                self.drawHole()
                self.setText()
                UIView.animate(withDuration: 0.4, animations: {
                    self.titleLabel.alpha = 1
                    self.descriptionLabel.alpha = 1
                })
            }
        }
    }

    private var isLastContent: Bool {
        return currentContentIndex == (content.count - 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        button.addTarget(self, action: #selector(buttonDidTouch), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        drawHole()
        setText()
    }

    @objc private func buttonDidTouch() {
        if isLastContent {
            dismiss(animated: true)
        } else {
            currentContentIndex += 1
        }
    }

    private func setText() {
        button.setTitle(isLastContent ? "Ок" : "Далее", for: .normal)
        titleLabel.text = content[currentContentIndex].data.title
        descriptionLabel.text = content[currentContentIndex].data.description
        let constant = content[currentContentIndex].itemRect!.origin.y + content[currentContentIndex].itemRect!.size.height + 40
        labelsStackView.topAnchor.constraint(equalTo: view.topAnchor,
                                             constant: constant).isActive = true
    }

    private func configureViews() {
        [blurView, button, labelsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.widthAnchor.constraint(equalToConstant: 204).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -94).isActive = true

        labelsStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        labelsStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        [titleLabel, descriptionLabel].forEach {
            labelsStackView.addArrangedSubview($0)
        }
    }

    private func drawHole() {
        let rect = content[currentContentIndex].itemRect!
        maskView = UIView(frame: UIScreen.main.bounds)
        maskView.clipsToBounds = true;
        maskView.backgroundColor = .clear

        let outerbezierPath = UIBezierPath(roundedRect: UIScreen.main.bounds, cornerRadius: 0)

        let x: CGFloat
        let y: CGFloat
        if content[currentContentIndex].side == .right {
            x = rect.origin.x - (highlightRadiusLength - (rect.size.width / 2))
            y = rect.origin.y - (highlightRadiusLength - (rect.size.height / 2))
        } else {
            x = rect.origin.x - ((rect.size.width / 2) - highlightRadiusLength)
            y = rect.origin.y - ((rect.size.height / 2) - highlightRadiusLength)
        }

        let newRect = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: highlightRadiusLength * 2, height: highlightRadiusLength * 2))

        let innerCirclepath = UIBezierPath.init(roundedRect: newRect, cornerRadius: newRect.height * 0.5)
        outerbezierPath.append(innerCirclepath)
        outerbezierPath.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.green.cgColor
        fillLayer.path = outerbezierPath.cgPath
        maskView.layer.addSublayer(fillLayer)

        blurView.mask = maskView
    }

    static func present(_ viewControllerToPresent: UIViewController, content: [FolioNavigationItemHighlighterContent]) {
        let vc = FolioNavigationItemHighlighterViewController()
        vc.content = content

        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        viewControllerToPresent.present(vc, animated: true)
    }
}
