/*
 * SwiftSRT
 * Copyright (c) 2020 Unpause SAS
 *
 * SRT - Secure, Reliable, Transport
 * Copyright (c) 2018 Haivision Systems Inc.
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 */

import Foundation

//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2020 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
/// An `Error` for an IO operation.
public struct IOError: Swift.Error {

    /// The actual reason (in an human-readable form) for this `IOError`.
    private var failureDescription: String

    /// The `errno` that was set for the operation.
    public let errnoCode: CInt

    /// Creates a new `IOError``
    ///
    /// - parameters:
    ///     - errorCode: the `errno` that was set for the operation.
    ///     - reason: the actual reason (in an human-readable form).
    public init(errnoCode: CInt, reason: String) {
        self.errnoCode = errnoCode
        self.failureDescription = reason
    }

}

/// Returns a reason to use when constructing a `IOError`.
///
/// - parameters:
///     - errorCode: the `errno` that was set for the operation.
///     - reason: what failed
/// - returns: the constructed reason.
private func reasonForError(errnoCode: CInt, reason: String) -> String {
    if let errorDescC = strerror(errnoCode) {
        return "\(reason): \(String(cString: errorDescC)) (errno: \(errnoCode))"
    } else {
        return "\(reason): Broken strerror, unknown error: \(errnoCode)"
    }
}

extension IOError: CustomStringConvertible {
    public var description: String {
        return self.localizedDescription
    }

    public var localizedDescription: String {
        return reasonForError(errnoCode: self.errnoCode, reason: self.failureDescription)
    }
}

/// An result for an IO operation that was done on a non-blocking resource.
enum IOResult<T: Equatable>: Equatable {

    /// Signals that the IO operation could not be completed as otherwise we would need to block.
    case wouldBlock(SrtMinorError)

    /// Signals that the IO operation was completed.
    case processed(T)
}
