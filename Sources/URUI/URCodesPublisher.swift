//
//  URCodesPublisher.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation
import Combine

public typealias URCodesPublisher = PassthroughSubject<Set<String>, Error>
