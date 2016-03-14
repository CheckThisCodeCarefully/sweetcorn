//
//  ViewController.swift
//  Sweetcorn
//
//  Created by Simon Gladman on 09/03/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import Cocoa

let model = SweetcornModel()

class ViewController: NSViewController, NSWindowDelegate, FilteringDelegate
{
    let monalisa = NSImage(named: "monalisa.jpg")!
    var ciMonaLisa: CIImage!
    
    let scrollView = NSScrollView()
    let canvas = Canvas(model: model, frame: CGRect(x: 0, y: 0, width: 2000, height: 2000))
    
    let imageView = NSImageView()
    let codeView = NSTextField()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.addSubview(scrollView)
        
        scrollView.documentView = canvas
        
        scrollView.hasHorizontalRuler = true
        scrollView.hasVerticalScroller = true
        
        imageView.image = monalisa
        
        codeView.font = NSFont.monospacedDigitSystemFontOfSize(10, weight: NSFontWeightMedium)
        codeView.editable = false
        codeView.backgroundColor = NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.95)
        
        view.addSubview(imageView)
        view.addSubview(codeView)
        
        let tiffData = monalisa.TIFFRepresentation!
        let bitmap = NSBitmapImageRep(data: tiffData)
        ciMonaLisa = CIImage(bitmapImageRep: bitmap!)
        
        model.filteringDelegate = self
        model.updateGLSL()
    }
    
    override func viewWillAppear()
    {
        view.window?.delegate = self
        
        scrollView.frame = view.frame
    }
    
    func glslDidUpdate(glslString: String)
    {
        codeView.stringValue = glslString
        
        let kernel = CIColorKernel(string: glslString)
        
        let filtered = kernel?.applyWithExtent(ciMonaLisa.extent, arguments: [ciMonaLisa])
        
        let xxx = NSCIImageRep(CIImage: filtered!)
        let final = NSImage(size: ciMonaLisa.extent.size)
        
        final.addRepresentation(xxx)
        
        imageView.image = final
    }
    
    
    func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize
    {
        scrollView.frame = CGRect(origin: CGPointZero, size: frameSize)
        
        imageView.frame = CGRect(x: frameSize.width - frameSize.height * 0.5,
            y: frameSize.height - frameSize.height * 0.5,
            width: frameSize.height * 0.5,
            height: frameSize.height * 0.5)
        
        codeView.frame = CGRect(x: frameSize.width - frameSize.height * 0.5,
            y: 0,
            width: frameSize.height * 0.5,
            height: frameSize.height * 0.5)
        
        return frameSize
    }
    
    
}
