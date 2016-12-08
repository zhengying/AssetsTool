//
//  AssetsConvert.swift
//  ZYAssetsTool
//
//  Created by zhengying on 8/5/16.
//  Copyright © 2016 zhengying. All rights reserved.
//

import Foundation

func createAssetsJSON(_ imageName:String) ->String {
    return "{\"images\" : [{\"idiom\" : \"universal\",\"filename\" : \"\(imageName).png\",\"scale\" : \"1x\"},{\"idiom\" : \"universal\",\"filename\" : \"\(imageName)@2x.png\",\"scale\" : \"2x\"},{\"idiom\" : \"universal\",\"filename\" : \"\(imageName)@3x.png\",\"scale\" : \"3x\"}],\"info\" : {\"version\" : 1,\"author\" : \"xcode\"}}"
}

typealias AssetsPathInfo = (path1x:String, path2x:String, path3x:String)
typealias AssetsImageInfo = [String:AssetsPathInfo]

func createAssetsImages(_ srcImagePath:String?, destPath:String? = nil) {
    guard let imagePath = srcImagePath else {
        return
    }
    
    //let srcImagePath = folderPathForInputImages()
    //var destPath = outputPath()
    var destPath = destPath
    
    if destPath == "" {
        destPath = (imagePath as NSString).deletingLastPathComponent + "_AssetsImages"
    }
    
    createFolderAtPath(destPath!, overwrite: true)
    
    let imagesInfos = foundImages(imagePath)
    
    imagesInfos.forEach { key, value in
        let assetsFilePath = appendPath(destPath!, key) + ".imageset"
        
        let fileName = (key as NSString).lastPathComponent
        let filetype = (value.path1x as NSString).pathExtension.lowercased()
        createFolderAtPath(assetsFilePath, overwrite: false, recursion: true)
        
        if value.path1x != "" {
            try! FileManager.default.copyItem(atPath: value.path1x, toPath: appendPath(assetsFilePath, fileName)+"."+filetype)
        } else {
            print("Warning: No 1x Image: \(assetsFilePath)")
        }
        
        if value.path2x != "" {
            try! FileManager.default.copyItem(atPath: value.path2x, toPath: appendPath(assetsFilePath, "\(fileName)@2x.\(filetype)"))
        } else {
            print("Warning: No 2x Image: \(assetsFilePath)")
        }
        
        if value.path3x != "" {
            try! FileManager.default.copyItem(atPath: value.path2x, toPath: appendPath(assetsFilePath, "\(fileName)@3x.\(filetype)"))
        } else {
            print("Warning: No 3x Image: \(assetsFilePath)")
        }
        
        let jsonContents = createAssetsJSON(fileName)
        let contentsJsonFile =  appendPath(assetsFilePath, "Contents.json")
        try! jsonContents.data(using: String.Encoding.utf8)!.write(to: URL(fileURLWithPath: contentsJsonFile), options: [])
        //NSData(contentsOfFile: jsonContents)?.writeToFile(contentsJsonFile, atomically: false)
    }
}

enum ImageScaleType:String {
    case Scale1x = "@1x"
    case Scale2x = "@2x"
    case Scale3x = "@3x"
}

func foundImage(_ scale:ImageScaleType, path:String, curPaths:[String]) -> [String]{
    var curPaths = curPaths
    let files = try! FileManager.default.contentsOfDirectory(atPath: path)
    files.filter({$0.hasPrefix(".") == false}).forEach { (file) in
        var isDir:ObjCBool = false
        let filePath = appendPath(path, file)
        if FileManager.default.fileExists(atPath: appendPath(path, file), isDirectory: &isDir) {
            if isDir.boolValue {
                curPaths = foundImage(scale, path: filePath, curPaths: curPaths)
            } else {
                if (file as NSString).pathExtension.lowercased() == "png" {
                    curPaths.append(filePath)
                }
            }
        }
    }
    return curPaths
}


func foundImages(_ path:String)->AssetsImageInfo {
    var assetsImageInfo = AssetsImageInfo()
    
    let files = try! FileManager.default.contentsOfDirectory(atPath: path)
    files.filter({$0.hasPrefix(".") == false}).forEach { (file) in
        let filePath = appendPath(path, file)
        [   ImageScaleType.Scale1x,
            ImageScaleType.Scale2x,
            ImageScaleType.Scale3x
        ].forEach({ (scaleType) in
            if file.contains(scaleType.rawValue) {
                let curPaths = foundImage(scaleType, path: filePath, curPaths: [])
                curPaths.forEach({ (findPath) in
                    let assetsKey = (findPath.replacingOccurrences(of: filePath, with: "") as NSString).deletingPathExtension.replacingOccurrences(of: scaleType.rawValue, with: "")
                    
                    print(assetsKey)
                    var fileList = assetsImageInfo[assetsKey] ?? (path1x:"", path2x:"", path3x:"")
                    switch scaleType {
                    case .Scale1x:
                        fileList.path1x = findPath
                    case .Scale2x:
                        fileList.path2x = findPath
                    case .Scale3x:
                        fileList.path3x = findPath
                    }
                    assetsImageInfo[assetsKey] = fileList
                })
            }
        })
    }
    
    return assetsImageInfo
}

// MARK:- tool function

private func createFolderAtPath(_ destPath:String, overwrite:Bool, recursion:Bool = false) {
    
    let fileExsit = FileManager.default.fileExists(atPath: destPath)
    if fileExsit && !overwrite {
        return
    }
    if fileExsit {
        try! FileManager.default.removeItem(atPath: destPath)
    }
    try! FileManager.default.createDirectory(atPath: destPath,withIntermediateDirectories: recursion, attributes: nil)
}

private func appendPath(_ path1:String,  _ path2:String)->String {
    return (path1 as NSString).appendingPathComponent(path2)
}
