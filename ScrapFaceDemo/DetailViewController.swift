//
//  DetailViewController.swift
//  ScrapFaceDemo
//
//  Created by Fumitoshi Ogata on 2015/01/07.
//  Copyright (c) 2015年 Fumitoshi Ogata. All rights reserved.
//

import UIKit

class DetailViewController : UIViewController {
    
    //スクロール
    @IBOutlet var scrollView: UIScrollView!
    
    //戻るボタン
    @IBOutlet var cancelButton: UIButton!
    @IBAction func cancelButtonDidTouch(sender: AnyObject) {
        performSegueWithIdentifier("UnwindCancelSegue",sender: nil)
    }
    
    //編集完了ボタン
    @IBOutlet var retouchButton: UIButton!
    @IBAction func retouchButtonDidTouch(sender: AnyObject) {
        performSegueWithIdentifier("UnwindEditingSegue",sender: nil)
    }

    //編集イメージ
    var editingImage : PhotoUIImageView!
    var previewImage : PhotoUIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        //プレビュー用のイメージ
        self.previewImage = PhotoUIImageView(image:UIImage(named:"filter_001.png"))
        self.previewImage.frame = CGRectMake(10,10,300,300)
        self.view.addSubview(self.previewImage)
        self.previewImage.image = self.editingImage.image
        self.previewImage.originalImage = self.editingImage.originalImage
        
        //フィルター用のスクロールビュー
        scrollView.frame  = CGRectMake(0,0,2000,2000)
        scrollView.contentSize = CGSizeMake(2000,80)
        scrollView.userInteractionEnabled = true;
        scrollView.scrollEnabled = true
        scrollView.delaysContentTouches = true
        scrollView.hidden = false
        
        //filter button
        for i in 1...10 {
            var _filterButton = UIButton()
            _filterButton.frame = CGRectMake(CGFloat(i*100),0,80,80)
            _filterButton.setImage(UIImage(named:"filter_001.png"), forState: .Normal)
            _filterButton.tag = i
            _filterButton.addTarget(self, action: "touchFilterButton:", forControlEvents:.TouchUpInside)
            self.scrollView.addSubview(_filterButton)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func touchFilterButton(sender: UIButton){
        self.previewImage?.image = self.previewImage?.originalImage?.getFilteredImage("CIPhotoEffectTonal")!
    }
    
    func touchEditButton(sender: UIButton){
    }
    
    func touchSizeButton(sender: UIButton){
    }
    
    // MARK: - キャバスページセグエにレタッチしたイメージを渡す

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        //編集完了の場合は、編集した画像を戻す
        if segue.identifier == "UnwindEditingSegue" {
            let dest : ViewController = segue.destinationViewController as ViewController            
            //dest.editingImage?.image = self.editingImage?.image
            dest.editingImage = self.editingImage
        }
        //キャンセルの場合は、なにもしない
        if segue.identifier == "UnwindCancelSegue" {
            let dest : ViewController = segue.destinationViewController as ViewController            
            //dest.editingImage?.image = UIImage(named:"scale_button.png")
            dest.editingImage = self.editingImage
        }
    }
}
