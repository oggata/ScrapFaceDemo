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

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ELCImagePickerControllerDelegate {

    var filterNum = 0
    var filterName = "filter_001"
    var pictures:[UIImage] = []
    var setPictures:[PhotoUIImageView] = []
    var setLabels:[UILabel]=[]
    
    var editingImage : PhotoUIImageView? = nil
    
    var canvasImageView : UIImageView!
    
    @IBOutlet var filterScrollView: UIScrollView!
    var filterUIView : UIImageView!
    
    var targetView : UIImageView!
    var targetButton01 : UIImageView!
    var isTargetButton01On : Bool = false
    var targetButton02 : UIImageView!
    var isTargetButton02On : Bool = false
    var targetButton03 : UIImageView!
    var isTargetButton03On : Bool = false
    var targetButton04 : UIImageView!
    var isTargetButton04On : Bool = false
        
    @IBOutlet var titileLabel: UILabel!
    var _posData : Array<Dictionary<String,String>> = []
    @IBOutlet var scrollView: TouchScrollView!
    var baseView : UIImageView!
    
    @IBOutlet var openAlbumButton: UIButton!
    @IBAction func openAlbumButtonDidTouch(sender: AnyObject) {
        //self.openAlbum()
        self.pickImages()
    }
    @IBOutlet var openFilterButton: UIButton!
    @IBAction func openFilterButtonDidTouch(sender: AnyObject) {
        self.changeFilter()
    }
    
    let uiButton: UIButton = UIButton()

    func getBrankImage() -> UIImage{
        var _targetImage : UIImage
        var _frame:CGRect = CGRect(x: 0,y:0,width:100,height:100)
        // ビットマップ形式のグラフィックスコンテキストの生成
        UIGraphicsBeginImageContextWithOptions(_frame.size,false,0.0);
        var _context : CGContextRef = UIGraphicsGetCurrentContext();
        var _rect : CGRect = CGRectMake(0,0,100,100);
        CGContextSetRGBStrokeColor(_context,1,0,0,1);
        CGContextStrokeRectWithWidth(_context,_rect,5);
        // 現在のグラフィックスコンテキストの画像を取得する
        _targetImage = UIGraphicsGetImageFromCurrentImageContext();
        // 現在のグラフィックスコンテキストへの編集を終了
        UIGraphicsEndImageContext();
        return _targetImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //スクロールビューを設定
        scrollView.frame  = CGRectMake(0,0,2000,2000)
        scrollView.contentSize = CGSizeMake(2000,2000)
        scrollView.userInteractionEnabled = true;
        scrollView.scrollEnabled = true
        scrollView.delaysContentTouches = true
        scrollView.minimumZoomScale = 0.2
        scrollView.maximumZoomScale = 8
        scrollView.rootView = self
        
        //スクロールビューと画像系の間に噛ませるView
        self.baseView = UIImageView(frame:scrollView.frame)
        self.scrollView.addSubview(self.baseView)
        self.targetView = UIImageView(image:self.getBrankImage())
        self.baseView.addSubview(self.targetView)
        self.targetView?.hidden = true
        
        //フィルター用のスクロールビュー
        filterScrollView.frame  = CGRectMake(0,0,2000,2000)
        filterScrollView.contentSize = CGSizeMake(2000,80)
        filterScrollView.userInteractionEnabled = true;
        filterScrollView.scrollEnabled = true
        filterScrollView.delaysContentTouches = true
        filterScrollView.hidden = false

        //filter button
        for i in 1...10 {
            var _filterButton = UIButton()
            _filterButton.frame = CGRectMake(CGFloat(i*100),0,80,80)
            _filterButton.setImage(UIImage(named:"filter_001.png"), forState: .Normal)
            _filterButton.tag = i
            _filterButton.addTarget(self, action: "touchFilterButton:", forControlEvents:.TouchUpInside)
            self.filterScrollView.addSubview(_filterButton)
        }
 
        //ボタン1
        self.targetButton01 = UIImageView(frame:CGRectMake(0,0,26,26))
        self.targetButton01.image = UIImage(named:"scale_button.png")
        self.targetView?.addSubview(self.targetButton01)
        
        self.targetButton02 = UIImageView(frame:CGRectMake(0,0,26,26))
        self.targetButton02.image = UIImage(named:"rotate_button.png")
        self.targetView?.addSubview(self.targetButton02)
        
        self.targetButton03 = UIImageView(frame:CGRectMake(0,0,26,26))
        self.targetButton03.image = UIImage(named:"up_button.png")
        self.targetView?.addSubview(self.targetButton03)
     
        self.targetButton04 = UIImageView(frame:CGRectMake(0,0,26,26))
        self.targetButton04.image = UIImage(named:"down_button.png")
        self.targetView?.addSubview(self.targetButton04)
        
        self.setImageEditorUI()
        
        self.changeFilter()
    }

    /*
    func tap(g:UIGestureRecognizer!) {
        println("tap! (gesture recognizer)")
    }*/
    
    func touchFilterButton(sender: UIButton){
        println("onClickButton:")
        println("sender.currentTitile: \(sender.currentTitle)")
        println("sender.tag:\(sender.tag)")
        //編集中イメージがある場合は、変種中イメージのoriginalImageにフィルターをかける<フィルター>
        if(self.editingImage != nil){
            self.editingImage?.image = self.editingImage?.image?.getFilteredImage("CIPhotoEffectTonal")!
        }
    }
    
    func touchSizeButton(sender: UIButton){
        //編集中イメージがある場合は、変種中イメージのoriginalImageにフィルターをかける<フィルター>
        if(self.editingImage != nil){
            self.editingImage?.image = self.editingImage?.image?.getFilteredImage("CIPhotoEffectTonal")!
        }
    }
    
    func touchDecorationButton(sender: UIButton){
        //編集中イメージがある場合は、変種中イメージのoriginalImageにフィルターをかける<フィルター>
        if(self.editingImage != nil){
            self.editingImage?.image = self.editingImage?.image?.getFilteredImage("CIPhotoEffectTonal")!
        }
    }
    
    // MARK: - 画像編集用のUIをセットする
    
    func setImageEditorUI(){

        if(self.editingImage != nil){
            var _x  = self.editingImage?.frame.origin.x
            var _y  = self.editingImage?.frame.origin.y
            var _width = self.editingImage?.frame.size.width
            var _height = self.editingImage?.frame.size.height
            self.targetView.frame = CGRectMake(
                _x!,
                _y!,
                _width!,
                _height!
            )
        }

        self.targetButton01.frame = CGRectMake(
            CGFloat(self.targetView.getUpperLeft().x-13),
            CGFloat(self.targetView.getUpperLeft().y-13),
            26,
            26
        )
        self.targetButton02.frame = CGRectMake(
            CGFloat(self.targetView.getUpperRight().x-13),
            CGFloat(self.targetView.getUpperRight().y-13),
            26,
            26
        )
        self.targetButton03.frame = CGRectMake(
            CGFloat(self.targetView.getLowerLeft().x-13),
            CGFloat(self.targetView.getLowerLeft().y-13),
            26,
            26
        )
        self.targetButton04.frame = CGRectMake(
            CGFloat(self.targetView.getLowerRight().x-13),
            CGFloat(self.targetView.getLowerRight().y-13),
            26,
            26
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toucheBegan(touches: NSSet){
        println("began")
        let t = touches.anyObject() as UITouch
        let point = t.locationInView(self.scrollView)
        var _imageViewPointX = point.x - self.baseView.frame.origin.x
        var _imageViewPointY = point.y - self.baseView.frame.origin.y
        
        //ボタンとの当り判定
        if(self.targetView.frame.origin.x + self.targetButton01.frame.origin.x <= _imageViewPointX
            && _imageViewPointX <= self.targetView.frame.origin.x + self.targetButton01.frame.origin.x + self.targetButton01.frame.size.width 
            && 
            self.targetView.frame.origin.y + self.targetButton01.frame.origin.y <= _imageViewPointY 
            && _imageViewPointY <= self.targetView.frame.origin.y + self.targetButton01.frame.origin.y + self.targetButton01.frame.size.height
            ){
                self.isTargetButton01On = true
        }
        
        if(self.targetView.frame.origin.x + self.targetButton02.frame.origin.x <= _imageViewPointX
            && _imageViewPointX <= self.targetView.frame.origin.x + self.targetButton02.frame.origin.x + self.targetButton02.frame.size.width 
            && 
            self.targetView.frame.origin.y + self.targetButton02.frame.origin.y <= _imageViewPointY 
            && _imageViewPointY <= self.targetView.frame.origin.y + self.targetButton02.frame.origin.y + self.targetButton02.frame.size.height
            ){
                self.isTargetButton02On = true
        }
        
        if(self.targetView.frame.origin.x + self.targetButton03.frame.origin.x <= _imageViewPointX
            && _imageViewPointX <= self.targetView.frame.origin.x + self.targetButton03.frame.origin.x + self.targetButton03.frame.size.width 
            && 
            self.targetView.frame.origin.y + self.targetButton03.frame.origin.y <= _imageViewPointY 
            && _imageViewPointY <= self.targetView.frame.origin.y + self.targetButton03.frame.origin.y + self.targetButton03.frame.size.height
            ){
                self.isTargetButton03On = true
        }
        
        if(self.targetView.frame.origin.x + self.targetButton04.frame.origin.x <= _imageViewPointX
            && _imageViewPointX <= self.targetView.frame.origin.x + self.targetButton04.frame.origin.x + self.targetButton04.frame.size.width 
            && 
            self.targetView.frame.origin.y + self.targetButton04.frame.origin.y <= _imageViewPointY 
            && _imageViewPointY <= self.targetView.frame.origin.y + self.targetButton04.frame.origin.y + self.targetButton04.frame.size.height
            ){
                self.isTargetButton04On = true
        }
        
        //ボタンと接触していない場合は編集中画像をリセットする
        if(!self.isTargetButton01On && !self.isTargetButton02On && !self.isTargetButton03On && !self.isTargetButton04On){
            self.editingImage = nil
        }
        
        //写真と接触している場合は、その写真が編集中イメージに入る
        for var i = 0; i < self.setPictures.count; i++ {
            println(self.setPictures[i].frame)
            if(self.setPictures[i].frame.origin.x <= _imageViewPointX 
                && _imageViewPointX <= self.setPictures[i].frame.origin.x + self.setPictures[i].frame.size.width 
                && self.setPictures[i].frame.origin.y <= _imageViewPointY 
                && _imageViewPointY <= self.setPictures[i].frame.origin.y + self.setPictures[i].frame.size.height
                ){
                    println("HIT!")                    
                    self.editingImage = setPictures[i]
            }
        }
        
        //ターゲッタを指定
        if(self.editingImage != nil){
            self.baseView.bringSubviewToFront(self.targetView)
            self.targetView?.hidden = false
            var _x  = self.editingImage?.frame.origin.x
            var _y  = self.editingImage?.frame.origin.y
            var _width = self.editingImage?.frame.size.width
            var _height = self.editingImage?.frame.size.height
            self.targetView.frame = CGRectMake(
                _x!,
                _y!,
                _width!,
                _height!
            )
            self.setImageEditorUI()
            
            if(self.isTargetButton03On){
                self.baseView.bringSubviewToFront(self.editingImage!)
            }
            if(self.isTargetButton04On){
                self.baseView.sendSubviewToBack(self.editingImage!)
            }
            
            //編集中イメージがある場合はキャンバス自体のスクロールを停止
            self.scrollView.scrollEnabled = false
            
        }else{
            self.targetView?.hidden = true
            
            //編集中イメージがない場合はキャンバス自体のスクロールを有効化
            self.scrollView.scrollEnabled = true
        }
    }
    
    var _imagePoint : CGPoint = CGPointMake(0,0)
    var _tmpImagePoint : CGPoint = CGPointMake(0,0)
    var _rt : Int = 0
    func touchMove(touches: NSSet){
        
        var _imagePoint : CGPoint = CGPointMake(0,0)
        var _tmpImagePoint : CGPoint = CGPointMake(0,0)
        var _rt : Int = 0
    
        let t = touches.anyObject() as UITouch
        let point = t.locationInView(self.scrollView)
        self._imagePoint = CGPointMake(point.x - self.baseView.frame.origin.x,point.y - self.baseView.frame.origin.y)
        
        //移動
        if(self.editingImage != nil){
            if(!self.isTargetButton01On && !self.isTargetButton02On && !self.isTargetButton03On && !self.isTargetButton04On){
                //アフィン変換されている場合は移動する前に一度初期化して、異動後に戻す必要がある
                var tmpTransform = self.editingImage!.transform
                if(!CGAffineTransformIsIdentity(self.editingImage!.transform)){
                    self.editingImage!.transform = CGAffineTransformIdentity
                }
                self.editingImage?.frame = CGRectMake(
                    self._imagePoint.x - self.editingImage!.frame.size.width / 2,
                    self._imagePoint.y - self.editingImage!.frame.size.height / 2,
                    self.editingImage!.frame.size.width,
                    self.editingImage!.frame.size.height
                )
                //戻す
                self.editingImage!.transform = tmpTransform
                
                //ターゲッタを指定
                if(self.editingImage != nil){
                    self.baseView.bringSubviewToFront(self.targetView)
                    self.targetView?.hidden = false
                    self.setImageEditorUI()
                }else{
                    self.targetView?.hidden = true
                }
                //スケール&ロテート
            }else{
                if(self.isTargetButton01On){
                    //アフィン変換されている場合は移動する前に一度初期化して、異動後に戻す必要がある
                    var tmpTransform = self.editingImage!.transform
                    if(!CGAffineTransformIsIdentity(self.editingImage!.transform)){
                        self.editingImage!.transform = CGAffineTransformIdentity
                    }
                    
                    if(self._tmpImagePoint.x > self._imagePoint.x){
                        self.editingImage?.frame = CGRectMake(
                            self.editingImage!.frame.origin.x - 1,
                            self.editingImage!.frame.origin.y - 1,
                            self.editingImage!.frame.size.width + 2,
                            self.editingImage!.frame.size.height + 2
                        )
                    }else{
                        self.editingImage?.frame = CGRectMake(
                            self.editingImage!.frame.origin.x + 1,
                            self.editingImage!.frame.origin.y + 1,
                            self.editingImage!.frame.size.width - 2,
                            self.editingImage!.frame.size.height - 2
                        )
                    }
                    
                    //戻す
                    self.editingImage!.transform = tmpTransform
                }
                
                //回転
                if(self.isTargetButton02On){
                    if(self._tmpImagePoint.x > self._imagePoint.x){
                        self._rt-=1
                    }else{
                        self._rt+=1
                    }
                    var _rad : CGFloat = CGFloat(CGFloat(self._rt) * CGFloat(M_PI / 180)) // 45°回転させたい場合
                    self.editingImage!.transform = CGAffineTransformMakeRotation(_rad)
                }
                
                //上下ソート
                if(self.isTargetButton03On){
                    self.baseView.bringSubviewToFront(self.editingImage!)
                }
                
                if(self.isTargetButton04On){
                    self.baseView.sendSubviewToBack(self.editingImage!)
                }                
            }
        }        
        self._tmpImagePoint = self._imagePoint
        self.setImageEditorUI()
    }
    
    func touchEnd(touches: NSSet){
        self.isTargetButton01On = false
        self.isTargetButton02On = false
        self.isTargetButton03On = false
        self.isTargetButton04On = false
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
                "frame":v["frame"].asString!
            ]
            
            _data["deco1_image"] = v["deco1_image"].asString!
            _data["deco1_pos_x"] = v["deco1_pos_x"].asString!
            _data["deco1_pos_y"] = v["deco1_pos_y"].asString!
            _data["deco1_scale"] = v["deco1_scale"].asString!
            _data["deco1_rotate"] = v["deco1_rotate"].asString!
            
            _data["deco2_image"] = v["deco2_image"].asString!
            _data["deco2_pos_x"] = v["deco2_pos_x"].asString!
            _data["deco2_pos_y"] = v["deco2_pos_y"].asString!
            _data["deco2_scale"] = v["deco2_scale"].asString!
            _data["deco2_rotate"] = v["deco2_rotate"].asString!
            
            _data["deco3_image"] = v["deco3_image"].asString!
            _data["deco3_pos_x"] = v["deco3_pos_x"].asString!
            _data["deco3_pos_y"] = v["deco3_pos_y"].asString!
            _data["deco3_scale"] = v["deco3_scale"].asString!
            _data["deco3_rotate"] = v["deco3_rotate"].asString!
                        
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
        self.baseView.backgroundColor = UIColor(patternImage: UIImage(named:_background!)!)
                
        //配置された写真をリムーブ
        self.removeAllPicturesFromCanvas()
                
        //写真をフィルタルールで配置しなおす
        self.arrangePicturesToCanvasByFilteringRule(self.filterName)
        
        //ターゲットUIを消す
        self.targetView?.hidden = true
    }
    
    // MARK: - Canvasから写真を削除

    func removeAllPicturesFromCanvas(){
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
    
    // MARK: - ScrollViewの制御
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!) -> UIView! {
        return self.baseView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView!, withView view: UIView!, atScale scale: CGFloat){
        //println(scale)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        //println(scrollView.contentOffset)
    }
    
    func getScrollViewCenterPos() -> CGPoint {
        return self.scrollView.contentOffset
    }
    

    // MARK: - Canvasに写真を配置
    
    func arrangePicturesToCanvasByFilteringRule(_filter : String) -> Void {
        for var i = 0; i < self.pictures.count; i++ {            
            var _picture : UIImage = self.pictures[i]
            self.setFilter(_picture)
        }
    }
    
    
    func setPictureByFilteringRule(){
        //var _image = UIImageView(image:_picture)
        if(self.editingImage != nil){
            var _edit = self.editingImage?.image
            self.editingImage?.image = _edit?.getKirinuki()
        }
    }
    
    
    // MARK: - 写真1枚の配置に対してフィルタを適用
    
    func setFilter(_originalImage:UIImage){

        var _image = UIImageView(image:_originalImage)
        var _i = self.setPictures.count
        if(_i>=9){
            var loginAlert:UIAlertController = UIAlertController(title: "写真は9枚迄です.", 
                message: "-製品版はもっと追加できますよ、乞うご期待!!-.", preferredStyle: UIAlertControllerStyle.Alert)
            loginAlert.addAction(UIAlertAction(title: "ok", style: .Default, handler: nil))
            self.presentViewController(loginAlert, animated: true, completion: nil)               
        }else{
            var _data = self._posData[Int(_i)]
            var _posX : CGFloat = CGFloat(_data["x"]!.toInt()!) 
            var _posY : CGFloat = CGFloat(_data["y"]!.toInt()!)
            var _maxLength : CGFloat = CGFloat(_data["width"]!.toInt()!)
            var _rotate : CGFloat = CGFloat(_data["rotate"]!.toInt()!)

            /*
            //rand
            //var _i = arc4random_uniform(9)
            var _pos = self.getRandPosition()
            var _posX = _pos.x            
            var _posY = _pos.y
            var _maxLength = CGFloat(100 + arc4random_uniform(300))
            */
            var _filteredImage = _originalImage
            if(_data["square"] == "true"){
                //_picture = _picture.getClippedImage(CGRectMake(0,0,500,500))
                _filteredImage = _filteredImage.getClippedImage2()
            }
            if(_data["filter"] != "none"){
                _filteredImage = _filteredImage.getFilteredImage(_data["filter"]!)!
            }
            if(_data["mask"] != "none"){
                var _image = UIImage(named:_data["mask"]!)
                _filteredImage = _filteredImage.getMaskedImage(_image!)
            }
            if(_data["frame"] == "INSTANT"){
                _filteredImage = _filteredImage.getPolaroidPhoto()
            }
            if(_data["frame"] == "LUXURY"){
                _filteredImage = _filteredImage.getPhoto2()
            }
            _filteredImage = _filteredImage.scaleToSize2(_maxLength)
            var _scaledView = PhotoUIImageView(image:_filteredImage)
            _scaledView.setOriginalImage(_originalImage)
            _scaledView.frame = CGRectMake(
                _posX,
                _posY,
                _filteredImage.size.width,
                _filteredImage.size.height
            )

            //回転はUIImageViewの方がやりやすいのでここで行う
            //var _rot = CGFloat(arc4random_uniform(30))
            var _rad = CGFloat(CGFloat(_rotate) * CGFloat(M_PI / 180)) // 45°回転させたい場合
            _scaledView.transform = CGAffineTransformMakeRotation(_rad);
            self.baseView.addSubview(_scaledView)
            self.setPictures.append(_scaledView)

            if(_data["deco1_image"] != ""){
                var _decoPosX : Float = Float(_data["deco1_pos_x"]!.toInt()!)
                var _decoPosY : Float = Float(_data["deco1_pos_y"]!.toInt()!)
                var _decoScale : Int = Int(_data["deco1_scale"]!.toInt()!)
                var _decoRotate : Int = Int(_data["deco1_rotate"]!.toInt()!)
                
                self.pasteDecoration(
                    _scaledView,
                    image : _data["deco1_image"]!,
                    posX : _decoPosX/100,
                    posY : _decoPosY/100,
                    Scale : _decoScale,
                    Rotate : _decoRotate
                )
            }
        }
    }
    
    // MARK: - デコレーションを貼る
    
    func pasteDecoration(targetPhoto:UIImageView,image:String,posX:Float,posY:Float,Scale:Int,Rotate:Int){
        var _decoImage = UIImage(named:image)
        //テープのイメージを描く
        _decoImage = _decoImage?.scaleToSize2(CGFloat(Scale))
        var _deco = PhotoUIImageView(image:_decoImage)
        var w : CGFloat? = _deco.image?.size.width
        var h : CGFloat? = _deco.image?.size.height
        
        //配置する場所を決める
        var _x = targetPhoto.frame.origin.x+CGFloat(targetPhoto.frame.size.width * CGFloat(posX))
        var _y = targetPhoto.frame.origin.y+CGFloat(targetPhoto.frame.size.height * CGFloat(posY))
        _deco.frame = CGRectMake(
            _x-CGFloat(w!/2),
            _y-CGFloat(h!/2),
            w!,
            h!
        )
        //_deco = _deco.getRandRotation()
        //_deco = _deco.setRotation(Rotate)
        self.baseView.addSubview(_deco)
        //self.setDecorations.append(_deco)
        self.setPictures.append(_deco)
    }
    
/*
        label.text = "I have a dream today!"
        label.textAlignment = NSTextAlignment.Center//整列
        //label.font = UIFont.systemFontOfSize(32);//文字サイズ
        label.font = UIFont(name: "Superclarendon-Black", size: 25)
        label.textColor = UIColor.whiteColor();////文字色
        //label.backgroundColor = UIColor.yellowColor();////背景色
        //label.numberOfLines = 0;
        label.sizeToFit();        
        self.view.addSubview(label)
        self.setLabels.append(label)
*/

    
    // MARK: - アルバムの制御
    
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
            
            self?.setFilter(_uiImage!)
        })
    }
    
    // MARK: - 1枚の写真を読み込む
    
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

    // MARK: - 複数毎の写真を読み込む
    
    // 写真を選択する
    func pickImages() {
        let picker = ELCImagePickerController()
        picker.maximumImagesCount = 5  // 選択する最大枚数
        picker.imagePickerDelegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    //  写真選択時に呼び出される
    func elcImagePickerController(picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if (info.count == 0) {
            return
        }
        var pickedImages = NSMutableArray()
        for any in info {
            let dict = any as NSMutableDictionary
            let image = dict.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
            pickedImages.addObject(image)
            
            //長辺500の写真として保存する
            var _scaledImage = image.scaleToSize2(CGFloat(500))
            //var _scaledImageView = UIImageView(image:_scaledImage) 
            
            //1枚ずつ保存する
            self.pictures.append(_scaledImage)
            self.setFilter(_scaledImage)
        }
        //println(pickedImages)
    }
    
    // 写真未選択時に呼び出される
    func elcImagePickerControllerDidCancel(picker: ELCImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

