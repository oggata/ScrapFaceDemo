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

    var filterNum = 0
    var filterName = "filter_001"
    var pictures:[UIImage] = []
    var setPictures:[UIImageView] = []
    var setDecorations:[UIImageView] = []
    
    @IBOutlet var titileLabel: UILabel!
    
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
        self.changeFilter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loadJSONFile(filterName:String) -> Array<Dictionary<String,String>>  {
        
        var filePath:String? = NSBundle.mainBundle().pathForResource(filterName,ofType:"json") as String?
        var err: NSError
        var fileHandle : NSFileHandle = NSFileHandle(forReadingAtPath: filePath!)!
        var acceptData : NSData = fileHandle.readDataToEndOfFile()
        let str = NSString(data:acceptData, encoding:NSUTF8StringEncoding)
        
        var rtnData:Array<Dictionary<String,String>> = []
        var parseJson = JSON.parse(str as NSString!)
        for (i, v) in parseJson {
            var _data = [
                "id":v["id"].asString!,
                "title":v["title"].asString!,
                "background":v["background"].asString!,
                "mask":v["mask"].asString!,
                "filter":v["filter"].asString!,
                "x":v["x"].asString!,
                "y":v["y"].asString!,
                "width":v["width"].asString!,
                "rotate":v["rotate"].asString!,
                "square":v["square"].asString!,
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
        
        //フィルター番号をインクリメント
        self.filterNum++
        if(self.filterNum>5){
            self.filterNum = 1
        }

        //TODO:定義ファイルにする
        //フィルタ番号からフィルタ名を索引する
        if(self.filterNum == 1){
            self.filterName = "filter_001"
        }
        if(self.filterNum == 2){
            self.filterName = "filter_002"
        }
        if(self.filterNum == 3){
            self.filterName = "filter_003"
        }
        if(self.filterNum == 4){
            self.filterName = "filter_004"
        }
        if(self.filterNum == 5){
            self.filterName = "filter_005"
        }
        self._posData = self.loadJSONFile(self.filterName)
        var _title = self._posData[0]["title"]
        var _background = self._posData[0]["background"]
        println(_title)
        self.titileLabel.text = _title
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:_background!)!)
                
        //配置された写真をリムーブ
        self.removeAllPicturesFromCanvas()
                
        //写真をフィルタルールで配置しなおす
        self.arrangePicturesToCanvasByFilteringRule(self.filterName)
    }
    
    // MARK: - Canvasから写真を削除

    func removeAllPicturesFromCanvas(){
        println("removeAll")
        //配列からremoveする。
        for var i = 0; i < self.setPictures.count; i++ {
            self.setPictures[i].removeFromSuperview()
            //self.setPictures.removeAtIndex(i)
        }
        
        for var i = 0; i < self.setDecorations.count; i++ {
            self.setDecorations[i].removeFromSuperview()
            //self.setPictures.removeAtIndex(i)
        }
        
        self.setPictures = [] 
        self.setDecorations = []
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
    
    // MARK: - 写真1枚の配置に対してフィルタルールを適用する
    
    func setPictureByFilteringRule2(_picture:UIImage,_filterName : String){
        var _image = UIImageView(image:_picture)

        var _i = self.setPictures.count
        if(_i>9){
            _i=0
        }
        
        //rand
        //var _i = arc4random_uniform(9)
        var _data = self._posData[Int(_i)]
        

        //var _data = self._posData[4]
        var _posX : CGFloat = CGFloat(_data["x"]!.toInt()!) 
        var _posY : CGFloat = CGFloat(_data["y"]!.toInt()!)
        var _maxLength : CGFloat = CGFloat(_data["width"]!.toInt()!)
        //var _rotate : CGFloat = CGFloat(_data["rotate"]!.toInt()!)
        var _rotate : CGFloat = CGFloat(_data["rotate"]!.toInt()!)

        /*
        //rand
        var _pos = self.getRandPosition()
        var _posX = _pos.x            
        var _posY = _pos.y
        var _maxLength = CGFloat(100 + arc4random_uniform(300))
        */
        var _picture = _picture
                
        if(_data["square"] == "true"){
            _picture = _picture.getClippedImage(CGRectMake(0,0,500,500))
        }
        if(_data["filter"] != "none"){
            _picture  = self.getSepiaFilterImage(_picture,filterName:_data["filter"]!)
        }
        if(_data["mask"] != "none"){
            _picture = _picture.getMaskedImage(_data["mask"]!)
        }

        //_picture = _picture.getPhoto()
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
        
        
        
        
        self.pasteTape(_scaledView)
    }

    /*
    func pasteFrame(){
    
    
    
    }*/
    
    
    func pasteTape(targetPhoto:UIImageView){
        
        //ランダムで5種類の中からテープを選ぶ
        var _tapeImage = UIImage(named:"tape_001.png")
        var rand = Int(arc4random_uniform(5) + 1)
        if(rand == 1){
            _tapeImage = UIImage(named:"tape_001.png")
        }
        if(rand == 2){
            _tapeImage = UIImage(named:"tape_002.png")
        }
        if(rand == 3){
            _tapeImage = UIImage(named:"tape_003.png")
        }
        if(rand == 4){
            _tapeImage = UIImage(named:"tape_004.png")
        }
        if(rand == 5){
            _tapeImage = UIImage(named:"tape_005.png")
        }
        
        //テープのイメージを描く
        _tapeImage = _tapeImage?.scaleToSize2(CGFloat(100))
        var _tape = UIImageView(image:_tapeImage)
        var w : CGFloat? = _tape.image?.size.width
        var h : CGFloat? = _tape.image?.size.height
        
        //配置する場所を決める
        var rand2 = Int(arc4random_uniform(2) + 1)
        //左上
        var _x = targetPhoto.frame.origin.x
        var _y = targetPhoto.frame.origin.y
        if(rand2 == 2){
            //右上
            _x = targetPhoto.frame.origin.x + targetPhoto.frame.size.width - w!
            _y = targetPhoto.frame.origin.y - h!/3
        }
        if(rand2 == 3){
            //中央
            _x = targetPhoto.frame.origin.x + targetPhoto.frame.size.width/2
            _y = targetPhoto.frame.origin.y - h!/3
        }

        _tape.frame = CGRectMake(
            _x,
            _y,
            w!,
            h!
        )
        _tape = _tape.getRandRotation()
        self.imageView.addSubview(_tape)
        self.setDecorations.append(_tape)
    }
    
    
    func pasteFukidashi(targetPhoto:UIImageView){
        //ランダムで5種類の中から吹き出しを選ぶ
        var _tapeImage = UIImage(named:"fukidashi_001.png")
        var rand = Int(arc4random_uniform(5) + 1)
        if(rand == 1){
            _tapeImage = UIImage(named:"fukidashi_001.png")
        }
        if(rand == 2){
            _tapeImage = UIImage(named:"fukidashi_002.png")
        }
        if(rand == 3){
            _tapeImage = UIImage(named:"fukidashi_003.png")
        }
        if(rand == 4){
            _tapeImage = UIImage(named:"fukidashi_004.png")
        }
        if(rand == 5){
            _tapeImage = UIImage(named:"fukidashi_005.png")
        }
        
        //テープのイメージを描く
        _tapeImage = _tapeImage?.scaleToSize2(CGFloat(100))
        var _tape = UIImageView(image:_tapeImage)
        var w : CGFloat? = _tape.image?.size.width
        var h : CGFloat? = _tape.image?.size.height
        
        //配置する場所を決める
        var rand2 = Int(arc4random_uniform(2) + 1)
        //左上
        var _x = targetPhoto.frame.origin.x
        var _y = targetPhoto.frame.origin.y + targetPhoto.frame.size.height / 2
        if(rand2 == 2){
            //右上
            _x = targetPhoto.frame.origin.x + targetPhoto.frame.size.width - w!
            _y = targetPhoto.frame.origin.y + targetPhoto.frame.size.height / 2
        }
        if(rand2 == 3){
            //中央
            _x = targetPhoto.frame.origin.x + targetPhoto.frame.size.width/2
            _y = targetPhoto.frame.origin.y + targetPhoto.frame.size.height / 2
        }
        
        _tape.frame = CGRectMake(
            _x,
            _y,
            w!,
            h!
        )
        _tape = _tape.getRandRotation()
        self.imageView.addSubview(_tape)
        self.setDecorations.append(_tape)
    }

    

    
    
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
    
    //func getTrimedImage() -> UIImage{
        //var clipRect = CGRectMake(0,0,500,500)
        //var cliped : CGImageRef = CGImageCreateWithImageInRect(srcImage.CGImage, clipRect);
        
        /*
        var trimingSize = CGSizeMake(500,500)
        var trimingRect = CGRectMake(
            0,
            0,
            500,
            500
        )
        //var trimedImage : CIImage = ciImage.imageByCroppingToRect(trimingRect)
        //var uiImage : UIImage = 
        var ciImage  = CIImage(CGImage:_uiImage?.CGImage)
        var context = CIContext(options: nil)
        var filteredImage: CIImage = ciImage.imageByCroppingToRect(trimingRect)
        var extent = filteredImage.extent()
        var cgImage:CGImageRef = context.createCGImage(filteredImage, fromRect: extent)
        var finalImage : UIImage? = UIImage(CGImage: cgImage)
        */
    //}    

    
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

