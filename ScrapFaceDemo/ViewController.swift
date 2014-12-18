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

    var filterNum = 1
    var pictures:[UIImage] = []
    var setPictures:[UIImageView] = []
    
    
    var _posData : Array<Dictionary<String,String>> = []
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var openAlbumButton: UIButton!
    @IBAction func openAlbumButtonDidTouch(sender: AnyObject) {
        println("xx")
        self.openAlbum()
    }
    @IBOutlet var openFilterButton: UIButton!
    @IBAction func openFilterButtonDidTouch(sender: AnyObject) {
        println("yy")
        self.changeFilter()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self._posData = []
        self._posData = self.loadJSONFile("aa")

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back_007.png")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setManufest(){
    
    }
    
    
    func loadJSONFile(tag:String) -> Array<Dictionary<String,String>>  {

        var filePath:String? = NSBundle.mainBundle().pathForResource("filter_001",ofType:"json") as String?
        var err: NSError
        var fileHandle : NSFileHandle = NSFileHandle(forReadingAtPath: filePath!)!
        var acceptData : NSData = fileHandle.readDataToEndOfFile()
        let str = NSString(data:acceptData, encoding:NSUTF8StringEncoding)
        
        var rtnData:Array<Dictionary<String,String>> = []
        var parseJson = JSON.parse(str as NSString!)
        for (i, v) in parseJson {
            var _data = [
                "id":v["id"].asString!,
                "mask":v["mask"].asString!,
                "filter":v["filter"].asString!,
                "x":v["x"].asString!,
                "y":v["y"].asString!,
                "width":v["width"].asString!,
                "rotate":v["rotate"].asString!,
            ]
            rtnData.append(_data)
        }
        
        //ID順でソートする
        sort(&rtnData) {
            (a:Dictionary, b:Dictionary) -> Bool in
            return a["id"] < b["id"]
        }
        
        return rtnData
    }
    
    func changeFilter(){
        //配置された写真をリムーブ
        self.removeAllPicturesFromCanvas()
        
        //背景のフィルターをセットする
        self.filterNum++
        if(self.filterNum>5){
            self.filterNum = 1
        }
        if(self.filterNum == 1){
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back_006.png")!)
        }
        if(self.filterNum == 2){
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back_002.png")!)
        }
        if(self.filterNum == 3){
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back_003.png")!)
        }
        if(self.filterNum == 4){
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back_004.png")!)
        }
        if(self.filterNum == 5){
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back_005.png")!)
        }
        
        //写真をフィルタルールで配置しなおす
        var _filterName = "hoge"
        self.arrangePicturesToCanvasByFilteringRule(_filterName)
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
    
    // MARK: - Canvasから写真を削除

    func removeAllPicturesFromCanvas(){
        println("remove")
        //配列からremoveする。
        for var i = 0; i < self.setPictures.count; i++ {
            self.setPictures[i].removeFromSuperview()
            //self.setPictures.removeAtIndex(i)
        }
        self.setPictures = []    
    }
    
    // MARK: - 既に配置されている写真に極力被らない座標を返す
    func getRandPosition() -> CGPoint{
        var cgPoint = CGPointMake(CGFloat(arc4random_uniform(200)),CGFloat(arc4random_uniform(300)))
        for var i = 0; i < 30; i++ {            
            var _x = CGFloat(arc4random_uniform(200))            
            var _y = CGFloat(arc4random_uniform(300))
            var _collisionCnt : Int = 0
            for var i = 0; i < self.setPictures.count; i++ {            
                var _picture : UIImageView = self.setPictures[i]
                var _frame = _picture.frame
                var centerPosX = CGFloat(_frame.origin.x + _frame.size.width/2)
                var centerPosY = CGFloat(_frame.origin.y + _frame.size.height/2)
                if(
                    (centerPosX - CGFloat(150) < _x) && (_x < centerPosX + CGFloat(150)) && 
                    (centerPosY - CGFloat(150) < _y) && (_y < centerPosY + CGFloat(150))
                )
                {
                    _collisionCnt++
                }
            }
            if(_collisionCnt == 0){
                cgPoint = CGPointMake(_x,_y)
            }
        }
        return cgPoint
    }
    

    // MARK: - Canvasに写真を配置
    
    func arrangePicturesToCanvasByFilteringRule(_filter : String) -> Void {
        for var i = 0; i < self.pictures.count; i++ {            
            var _picture : UIImage = self.pictures[i]
            self.setPictureByFilteringRule2(_picture,_filterName:"aa")
        }
    }
    
    
    
    func setPictureByFilteringRule2(_picture:UIImage,_filterName : String){
        var _image = UIImageView(image:_picture)

        var _i = arc4random_uniform(9)
        var _data = self._posData[Int(_i)]

        //var _data = self._posData[4]
        var _posX : CGFloat = CGFloat(_data["x"]!.toInt()!) 
        var _posY : CGFloat = CGFloat(_data["y"]!.toInt()!)
        var _maxLength : CGFloat = CGFloat(_data["width"]!.toInt()!)
        var _rotate : CGFloat = CGFloat(_data["rotate"]!.toInt()!)

        /*
        var _pos = self.getRandPosition()
        var _posX = _pos.x            
        var _posY = _pos.y
        var _maxLength = CGFloat(100 + arc4random_uniform(300))
        */
        var _picture = _picture
        if(_data["mask"] != "none"){
            _picture = _picture.getMaskedImage(_data["mask"]!)
        }
        if(_data["filter"] != "none"){
            _picture  = self.getSepiaFilterImage(_picture,filterName:_data["filter"]!)
        }
        var _scaledImage : UIImage = _picture.scaleToSize2(_maxLength)
        var _scaledView = UIImageView(image:_scaledImage)
        _scaledView.frame = CGRectMake(
            _posX,
            _posY,
            _scaledImage.size.width,
            _scaledImage.size.height
        )
        //回転はUIImageViewの方がやりやすいのでここで行う
        //var _rot = CGFloat(arc4random_uniform(30))
        var _rad = CGFloat(CGFloat(_rotate) * CGFloat(M_PI / 180)) // 45°回転させたい場合
        _scaledView.transform = CGAffineTransformMakeRotation(_rad);
        self.imageView.addSubview(_scaledView)
        self.setPictures.append(_scaledView)
    }
    
    // MARK: - 写真1枚の配置に対してフィルタルールを適用する
    /*
    func setPictureByFilteringRule(_picture:UIImage,_filterName : String){
        var _image = UIImageView(image:_picture)
        var _pos = self.getRandPosition()
        var _posX = _pos.x            
        var _posY = _pos.y
        //var _rotate = CGFloat(30 * -1 + arc4random_uniform(60))
        var _maxLength = CGFloat(100 + arc4random_uniform(300))
        //var _picture = _picture.getMaskedImage()
        //var _picture  = self.getSepiaFilterImage(_picture,filterName:"CIPhotoEffectTransfer")
        var _scaledImage : UIImage = _picture.scaleToSize2(_maxLength)
        var _scaledView = UIImageView(image:_scaledImage)
        _scaledView.frame = CGRectMake(
            _posX,
            _posY,
            _scaledImage.size.width,
            _scaledImage.size.height
        )
        //回転はUIImageViewの方がやりやすいのでここで行う
        var _rot = CGFloat(arc4random_uniform(30))
        var _rad = CGFloat(CGFloat(_rot) * CGFloat(M_PI / 180)) // 45°回転させたい場合
        _scaledView.transform = CGAffineTransformMakeRotation(_rad);
        self.imageView.addSubview(_scaledView)
        self.setPictures.append(_scaledView)
    }*/

    //画像にフィルターをかける
    func getSepiaFilterImage(baseImage:UIImage,filterName:String) -> UIImage{
        var filter = CIFilter(name:filterName)
        var unfilteredImage = CIImage(CGImage:baseImage.CGImage)
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        var context = CIContext(options: nil)
        var filteredImage: CIImage = filter.outputImage
        var extent = filteredImage.extent()
        var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        var finalImage = UIImage(CGImage: cgImage)
        return finalImage!
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
            
            var _uiImage : UIImage? = imageFromAlbum
            _uiImage = _uiImage?.scaleToSize2(CGFloat(500))
            var _image = UIImageView(image:_uiImage)            
            
            //開いた写真を長辺500の写真として保存しておく
            self?.pictures.append(_uiImage!)
            
            self?.setPictureByFilteringRule2(_uiImage!,_filterName : "hoge")
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

