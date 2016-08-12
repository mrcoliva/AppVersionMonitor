// AppVersionMonitor.swift
//
// Copyright (c) 2015 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

public class AppVersionMonitor {
        
    public enum State {
        case notChanged
        case installed
        case upgraded(previousVersion: AppVersion)
        case downgraded(previousVersion: AppVersion)
    }
    
    public static let sharedMonitor = AppVersionMonitor()
    
    public let state: State
    public let installedVersions: [AppVersion]
    
    public func startup() {
        
    }
    
    init() {
        
        let userDefaults = UserDefaults(suiteName: AppVersionMonitor.userDefaultsSuitename)
        defer {
            userDefaults?.synchronize()
        }
        
        var installedVersions = (userDefaults?.object(forKey: AppVersionMonitor.installedVersionsKey) as? [String])?.map { AppVersion($0) } ?? []
        
        let _latestVersionString = userDefaults?.string(forKey: AppVersionMonitor.latestVersionKey)
        userDefaults?.set(AppVersion.marketingVersion.versionString, forKey: AppVersionMonitor.latestVersionKey)
        
        if installedVersions.contains(AppVersion.marketingVersion) == false {
            
            installedVersions.append(AppVersion.marketingVersion)
            userDefaults?.set(installedVersions.map { $0.versionString }, forKey: AppVersionMonitor.installedVersionsKey)
        }
        
        self.installedVersions = installedVersions

        guard let latestVersionString = _latestVersionString else {
            
            self.state = .installed
            return
            
        }
        
        let latestVersion = AppVersion(latestVersionString)
        
        if latestVersion < AppVersion.marketingVersion {
            
            self.state = .upgraded(previousVersion: latestVersion)
            
        } else if latestVersion > AppVersion.marketingVersion {
            
            self.state = .downgraded(previousVersion: latestVersion)
            
        } else {
            
            self.state = .notChanged
        }
    }
    
    private static let latestVersionKey = "me.muukii.AppVersionMonitor.latestVersion"
    private static let installedVersionsKey = "me.muukii.AppVersionMonitor.installedVersionsKey"
    private static let userDefaultsSuitename = "me.muukii.AppVersionMonitor"
}
