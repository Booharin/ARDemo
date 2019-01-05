//
//  VirtualObject.swift
//  ARDemo
//
//  Created by Booharin on 05/01/2019.
//  Copyright © 2019 Booharin. All rights reserved.
//

import SceneKit

class VirtualObject: SCNReferenceNode {
    static let availableObjects: [SCNReferenceNode] = {
        guard let modelsUrls = Bundle.main.url(forResource: "art.scnassets",
                                               withExtension: nil) else { return [] }
        let fileEnumerator = FileManager().enumerator(at: modelsUrls, includingPropertiesForKeys: nil)!
        
        return fileEnumerator.compactMap { element in
            let url = element as! URL
            guard url.pathExtension == "scn" else { return nil }
            return VirtualObject(url: url)
        }
    }()
}
