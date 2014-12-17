//
//  ViewController.swift
//  ScrapFaceDemo
//
//  Created by Fumitoshi Ogata on 2014/12/17.
//  Copyright (c) 2014年 Fumitoshi Ogata. All rights reserved.
//

import UIKit
import Photos
import CoreImage

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var openAlbumButton: UIButton!
    @IBAction func openAlbumButtonDidTouch(sender: AnyObject) {
        println("xx")
        self.openAlbum()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //マスクされた画像を作成
    func getMaskedImage(originalImage:UIImage!,maskImage:UIImage!) -> UIImage {        
        let maskImageReference:CGImage? = maskImage?.CGImage
        let mask = CGImageMaskCreate(CGImageGetWidth(maskImageReference),
            CGImageGetHeight(maskImageReference),
            CGImageGetBitsPerComponent(maskImageReference),
            CGImageGetBitsPerPixel(maskImageReference),
            CGImageGetBytesPerRow(maskImageReference),
            CGImageGetDataProvider(maskImageReference),nil,false)
        let maskedImageReference = CGImageCreateWithMask(originalImage?.CGImage, mask)
        let maskedImage = UIImage(CGImage: maskedImageReference)
        return maskedImage!
    }

    // MARK: - 写真の制御
    
    private func openAlbum() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        imagePicker.delegate = self
        //loading = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!)  {
        
        //AssetLibrary frameworkによって提供されるURLを取得する
        let assetUrlOptional: NSURL? = info[UIImagePickerControllerReferenceURL] as? NSURL
        if assetUrlOptional == nil {
            NSLog("Error: no asset URL")
            //loading = false
            return
        }
        let assetUrl = assetUrlOptional!
        
        //取得したURLを使用して、PHAssetを取得する
        let fetchResult = PHAsset.fetchAssetsWithALAssetURLs([ assetUrl ], options: nil)
        if fetchResult.firstObject == nil {
            NSLog("Error: asset not fetched")
            //loading = false
            return
        }
        let asset = fetchResult.firstObject! as PHAsset
        
        //Assetが編集処理をサポートしているかを問い合わせする
        if !asset.canPerformEditOperation(PHAssetEditOperation.Content) {
            NSLog("Error: asset can't be edited")
            //loading = false
            return
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        loadAsset(asset, completion: { [weak self] (imageFromAlbum:UIImage) -> Void in

            var _image = UIImageView(image:imageFromAlbum)
            var _uiImage = _image.image
            //var _uiImage = UIImage(named:"syugou.jpg")

            /*
            var _image = UIImageView(image:_uiImage)
            var w : CGFloat? = _uiImage?.size.width
            var h : CGFloat? = _uiImage?.size.height
            var scale:CGFloat
            if(w>h){
                scale = CGFloat(300/w!)
            }else{
                scale = CGFloat(300/h!)
            }            
            _image.frame = CGRectMake(
                120,
                120,
                CGFloat(w! * scale),
                CGFloat(h! * scale)
            )
            //self?.imageView.addSubview(_image)
            */
            var ciImage  = CIImage(CGImage:_uiImage?.CGImage)
            var ciDetector = CIDetector(ofType:CIDetectorTypeFace
                ,context:nil
                ,options:[
                    CIDetectorAccuracy:CIDetectorAccuracyHigh,
                    CIDetectorSmile:true
                ]
            )
            var features = ciDetector.featuresInImage(ciImage)
            if (features != nil) {

                var _cnt = 0
                for feature in features{
                    //context
                    var drawCtxt = UIGraphicsGetCurrentContext()
                    var faceRect = (feature as CIFaceFeature).bounds
                    //faceRect.origin.y = h! - faceRect.origin.y - faceRect.size.height
                    _cnt++

                    var trimingSize = CGSizeMake(faceRect.size.width,faceRect.size.height)
                    var trimingRect = CGRectMake(
                        faceRect.origin.x,
                        faceRect.origin.y,
                        faceRect.size.width,
                        faceRect.size.height
                    )
                    //var trimedImage : CIImage = ciImage.imageByCroppingToRect(trimingRect)
                    //var uiImage : UIImage = 
                    var context = CIContext(options: nil)
                    var filteredImage: CIImage = ciImage.imageByCroppingToRect(trimingRect)
                    var extent = filteredImage.extent()
                    var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
                    var finalImage : UIImage? = UIImage(CGImage: cgImage)
                

                    finalImage = finalImage?.scaleToSize(CGSize(width:80,height:80))
                    var _maskedImage = self?.getMaskedImage(finalImage,maskImage:UIImage(named:"face_mask.png"))

                    var _fImage = UIImageView(image:_maskedImage)
                    var _posX = arc4random_uniform(300);
                    var _posY = arc4random_uniform(500);
                    var _sizeW = 40 + arc4random_uniform(80);
                    _fImage.frame = CGRectMake(
                        CGFloat(_posX),
                        CGFloat(_posY),
                        60,
                        60
                    )

                    var _utyujin = UIImageView(image:UIImage(named:"utyujin.png"))
                    _utyujin.frame = CGRectMake(CGFloat(_posX-10),CGFloat(_posY-10),132,257)
                    self?.imageView.addSubview(_utyujin)

                    self?.imageView.addSubview(_fImage)
                }
                println(_cnt)
                return
            }
        })
    }
    
    var asset: PHAsset?
    
    private func loadAsset(asset: PHAsset?, completion: ((hoge:UIImage) -> Void)?) {
        
        let asset = asset!
        
        //self.libImage = CIImage(CGImage: UIImage(named:"star-32.png")?.CGImage)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { [weak self] () -> Void in
            
            //PHContentEditingInputRequestOptionsを作成、canHandleAdjustmentDataをセット
            let options = PHContentEditingInputRequestOptions()
            
            //Assetのコンテンツ編集セッションを開始するために必要な情報をリクエスト
            asset.requestContentEditingInputWithOptions(options, completionHandler: { (input, info) -> Void in
                
                var uiImageFromLibrary:UIImage!
                
                if input.displaySizeImage == nil{
                    NSLog("Loaded asset WITHOUT adjustment data")
                }
                else{
                    //var url = input.fullSizeImageURL
                    //var url = input.displaySizeImage
                    var ciImageFromLibrary =  CIImage(image: input?.displaySizeImage)
                    uiImageFromLibrary = UIImage(CIImage: ciImageFromLibrary);
                }
                if let completion = completion {
                    completion(hoge: uiImageFromLibrary)
                }
            })
        })
    }

}

