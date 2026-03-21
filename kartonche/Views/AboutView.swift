//
//  AboutView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import StoreKit

struct AboutView: View {
    @Environment(\.requestReview) private var requestReview
    @State private var showingLicense = false
    @State private var showingPrivacy = false
    @State private var showingWhatsNew = false
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        List {
            // App Header
            Section {
                VStack(spacing: 12) {
                    Image("AboutIcon")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    
                    Text("kartonche")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(String(localized: "Version \(appVersion) (\(buildNumber))", comment: "App version and build number in About screen"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
            
            // About Section
            Section {
                Text(String(localized: "A simple app for organizing your loyalty cards. Open source, privacy-focused, no account required.", comment: "App description in About screen"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "About", comment: "Section header in About screen"))
            }

            // Legal Section
            Section {
                Button {
                    showingLicense = true
                } label: {
                    Label {
                        Text(String(localized: "License", comment: "Button to view the app's open source license"))
                    } icon: {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.tint)
                    }
                }
                .foregroundStyle(.primary)
                
                Button {
                    showingPrivacy = true
                } label: {
                    Label {
                        Text(String(localized: "Privacy", comment: "Button to view privacy policy"))
                    } icon: {
                        Image(systemName: "hand.raised")
                            .foregroundStyle(.tint)
                    }
                }
                .foregroundStyle(.primary)
            } header: {
                Text(String(localized: "Legal", comment: "Section header for license and privacy links"))
            }
            
            // Third-Party Licenses Section
            Section {
                NavigationLink {
                    ThirdPartyLicensesView()
                } label: {
                    Label(String(localized: "Third-Party Licenses", comment: "Link to view licenses of third-party libraries"), systemImage: "doc.on.doc")
                }
            } header: {
                Text(String(localized: "Licenses", comment: "Section header for third-party license links"))
            }

            // Support Section
            Section {
                Button {
                    requestReview()
                } label: {
                    Label {
                        Text(String(localized: "Rate on App Store", comment: "Button to leave a review on the App Store"))
                    } icon: {
                        Image(systemName: "star")
                            .foregroundStyle(.tint)
                    }
                }
                .foregroundStyle(.primary)
                
                Link(destination: URL(string: "https://github.com/zbrox/kartonche/issues")!) {
                    Label {
                        Text(String(localized: "Report an Issue", comment: "Link to open GitHub issues page for bug reports"))
                    } icon: {
                        Image(systemName: "ladybug")
                            .foregroundStyle(.tint)
                    }
                }
                .foregroundStyle(.primary)
                
                Button {
                    // Placeholder for future donation link
                } label: {
                    Label(String(localized: "Support Development", comment: "Button for future donation/support feature"), systemImage: "cup.and.saucer")
                }
                .foregroundStyle(.secondary)
                .disabled(true)
            } header: {
                Text(String(localized: "Support", comment: "Section header for support and feedback links"))
            }
            
            // More Section
            Section {
                Button {
                    showingWhatsNew = true
                } label: {
                    Label {
                        Text(String(localized: "What's New", comment: "Button to view changelog / release notes"))
                    } icon: {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.tint)
                    }
                }
                .foregroundStyle(.primary)
                
                Link(destination: URL(string: "https://github.com/zbrox/kartonche")!) {
                    Label {
                        Text(String(localized: "Source Code", comment: "Link to view the app's source code on GitHub"))
                    } icon: {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .foregroundStyle(.tint)
                    }
                }
                .foregroundStyle(.primary)
            } header: {
                Text(String(localized: "More", comment: "Section header for additional links like changelog and source code"))
            }
            
            // Credits
            Section {
                Text(String(localized: "Thanks to early testers and friends who provided feedback.", comment: "Credits message at the bottom of About screen"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(String(localized: "About", comment: "Navigation title for About screen"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingLicense) {
            LicenseView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
        .sheet(isPresented: $showingWhatsNew) {
            WhatsNewView()
        }
    }
}

struct LicenseView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let licenseText = """
    MIT License
    
    Copyright (c) 2026 Rostislav Raykov
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    """
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(licenseText)
                    .font(.footnote)
                    .padding()
            }
            .navigationTitle(String(localized: "MIT License", comment: "Navigation title for license text view"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", comment: "Button to dismiss license view")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(String(localized: "Privacy Policy", comment: "Title of the privacy policy page"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "kartonche stores your cards on-device and can sync them through your private iCloud account. We don't collect, track, or share personal information.", comment: "Privacy policy overview paragraph"))
                        
                        Text(String(localized: "No account required", comment: "Privacy policy heading: no signup needed"))
                            .fontWeight(.semibold)
                        Text(String(localized: "Your cards stay on this device by default. If iCloud is enabled, they also sync through your private iCloud database.", comment: "Privacy policy explanation of data storage"))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "No analytics", comment: "Privacy policy heading: no usage tracking"))
                            .fontWeight(.semibold)
                        Text(String(localized: "We don't track how you use the app.", comment: "Privacy policy explanation of no-analytics policy"))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "No ads", comment: "Privacy policy heading: no advertising"))
                            .fontWeight(.semibold)
                        Text(String(localized: "The app contains no advertising.", comment: "Privacy policy explanation of no-ads policy"))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "Location data", comment: "Privacy policy heading: location data usage"))
                            .fontWeight(.semibold)
                        Text(String(localized: "If you enable location features, your location is used only to show cards for nearby stores and is never sent to any server.", comment: "Privacy policy explanation of location data handling"))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding()
            }
            .navigationTitle(String(localized: "Privacy", comment: "Navigation title for privacy policy screen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", comment: "Button to dismiss privacy policy view")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(whatsNewVersions, id: \.version) { version in
                    Section {
                        ForEach(version.features, id: \.icon) { feature in
                            FeatureRow(
                                icon: feature.icon,
                                title: String(localized: feature.title),
                                description: String(localized: feature.description)
                            )
                        }
                    } header: {
                        Text(verbatim: String(format: String(localized: "whats_new.version_format"), version.version))
                    }
                }
            }
            .navigationTitle(String(localized: "What's New", comment: "Navigation title for changelog screen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", comment: "Button to dismiss changelog view")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Third-Party Licenses

fileprivate enum ThirdPartyLicense: String, CaseIterable, Identifiable {
    case swiftCertificates
    case swiftCrypto
    case swiftASN1
    case swiftDataMatrix
    case zipFoundation

    var id: String { rawValue }

    var name: String {
        switch self {
        case .swiftCertificates: "swift-certificates"
        case .swiftCrypto: "swift-crypto"
        case .swiftASN1: "swift-asn1"
        case .swiftDataMatrix: "SwiftDataMatrix"
        case .zipFoundation: "ZIPFoundation"
        }
    }

    var licenseType: String {
        switch self {
        case .swiftCertificates, .swiftCrypto, .swiftASN1: "Apache 2.0"
        case .swiftDataMatrix, .zipFoundation: "MIT"
        }
    }

    var licenseText: String {
        switch self {
        case .swiftCertificates, .swiftCrypto, .swiftASN1: ThirdPartyLicenseTexts.apache2
        case .zipFoundation: ThirdPartyLicenseTexts.mitZIPFoundation
        case .swiftDataMatrix: ThirdPartyLicenseTexts.mitSwiftDataMatrix
        }
    }

    var copyright: String {
        switch self {
        case .swiftCertificates: "Copyright 2022 The SwiftCertificates Project"
        case .swiftCrypto: "Copyright 2019 The SwiftCrypto Project"
        case .swiftASN1: "Copyright 2022 The SwiftASN1 Project"
        case .swiftDataMatrix: "Copyright 2026 Daniel Höpfl"
        case .zipFoundation: "Copyright (c) 2017-2025 Thomas Zoechling (https://www.peakstep.com)"
        }
    }
}

private enum ThirdPartyLicenseTexts {
    // Verbatim from swift-certificates/swift-crypto/swift-asn1 LICENSE.txt
    // swiftlint:disable:next line_length
    static let apache2 = """
                                     Apache License
                               Version 2.0, January 2004
                            http://www.apache.org/licenses/

       TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

       1. Definitions.

          "License" shall mean the terms and conditions for use, reproduction,
          and distribution as defined by Sections 1 through 9 of this document.

          "Licensor" shall mean the copyright owner or entity authorized by
          the copyright owner that is granting the License.

          "Legal Entity" shall mean the union of the acting entity and all
          other entities that control, are controlled by, or are under common
          control with that entity. For the purposes of this definition,
          "control" means (i) the power, direct or indirect, to cause the
          direction or management of such entity, whether by contract or
          otherwise, or (ii) ownership of fifty percent (50%) or more of the
          outstanding shares, or (iii) beneficial ownership of such entity.

          "You" (or "Your") shall mean an individual or Legal Entity
          exercising permissions granted by this License.

          "Source" form shall mean the preferred form for making modifications,
          including but not limited to software source code, documentation
          source, and configuration files.

          "Object" form shall mean any form resulting from mechanical
          transformation or translation of a Source form, including but
          not limited to compiled object code, generated documentation,
          and conversions to other media types.

          "Work" shall mean the work of authorship, whether in Source or
          Object form, made available under the License, as indicated by a
          copyright notice that is included in or attached to the work
          (an example is provided in the Appendix below).

          "Derivative Works" shall mean any work, whether in Source or Object
          form, that is based on (or derived from) the Work and for which the
          editorial revisions, annotations, elaborations, or other modifications
          represent, as a whole, an original work of authorship. For the purposes
          of this License, Derivative Works shall not include works that remain
          separable from, or merely link (or bind by name) to the interfaces of,
          the Work and Derivative Works thereof.

          "Contribution" shall mean any work of authorship, including
          the original version of the Work and any modifications or additions
          to that Work or Derivative Works thereof, that is intentionally
          submitted to Licensor for inclusion in the Work by the copyright owner
          or by an individual or Legal Entity authorized to submit on behalf of
          the copyright owner. For the purposes of this definition, "submitted"
          means any form of electronic, verbal, or written communication sent
          to the Licensor or its representatives, including but not limited to
          communication on electronic mailing lists, source code control systems,
          and issue tracking systems that are managed by, or on behalf of, the
          Licensor for the purpose of discussing and improving the Work, but
          excluding communication that is conspicuously marked or otherwise
          designated in writing by the copyright owner as "Not a Contribution."

          "Contributor" shall mean Licensor and any individual or Legal Entity
          on behalf of whom a Contribution has been received by Licensor and
          subsequently incorporated within the Work.

       2. Grant of Copyright License. Subject to the terms and conditions of
          this License, each Contributor hereby grants to You a perpetual,
          worldwide, non-exclusive, no-charge, royalty-free, irrevocable
          copyright license to reproduce, prepare Derivative Works of,
          publicly display, publicly perform, sublicense, and distribute the
          Work and such Derivative Works in Source or Object form.

       3. Grant of Patent License. Subject to the terms and conditions of
          this License, each Contributor hereby grants to You a perpetual,
          worldwide, non-exclusive, no-charge, royalty-free, irrevocable
          (except as stated in this section) patent license to make, have made,
          use, offer to sell, sell, import, and otherwise transfer the Work,
          where such license applies only to those patent claims licensable
          by such Contributor that are necessarily infringed by their
          Contribution(s) alone or by combination of their Contribution(s)
          with the Work to which such Contribution(s) was submitted. If You
          institute patent litigation against any entity (including a
          cross-claim or counterclaim in a lawsuit) alleging that the Work
          or a Contribution incorporated within the Work constitutes direct
          or contributory patent infringement, then any patent licenses
          granted to You under this License for that Work shall terminate
          as of the date such litigation is filed.

       4. Redistribution. You may reproduce and distribute copies of the
          Work or Derivative Works thereof in any medium, with or without
          modifications, and in Source or Object form, provided that You
          meet the following conditions:

          (a) You must give any other recipients of the Work or
              Derivative Works a copy of this License; and

          (b) You must cause any modified files to carry prominent notices
              stating that You changed the files; and

          (c) You must retain, in the Source form of any Derivative Works
              that You distribute, all copyright, patent, trademark, and
              attribution notices from the Source form of the Work,
              excluding those notices that do not pertain to any part of
              the Derivative Works; and

          (d) If the Work includes a "NOTICE" text file as part of its
              distribution, then any Derivative Works that You distribute must
              include a readable copy of the attribution notices contained
              within such NOTICE file, excluding those notices that do not
              pertain to any part of the Derivative Works, in at least one
              of the following places: within a NOTICE text file distributed
              as part of the Derivative Works; within the Source form or
              documentation, if provided along with the Derivative Works; or,
              within a display generated by the Derivative Works, if and
              wherever such third-party notices normally appear. The contents
              of the NOTICE file are for informational purposes only and
              do not modify the License. You may add Your own attribution
              notices within Derivative Works that You distribute, alongside
              or as an addendum to the NOTICE text from the Work, provided
              that such additional attribution notices cannot be construed
              as modifying the License.

          You may add Your own copyright statement to Your modifications and
          may provide additional or different license terms and conditions
          for use, reproduction, or distribution of Your modifications, or
          for any such Derivative Works as a whole, provided Your use,
          reproduction, and distribution of the Work otherwise complies with
          the conditions stated in this License.

       5. Submission of Contributions. Unless You explicitly state otherwise,
          any Contribution intentionally submitted for inclusion in the Work
          by You to the Licensor shall be under the terms and conditions of
          this License, without any additional terms or conditions.
          Notwithstanding the above, nothing herein shall supersede or modify
          the terms of any separate license agreement you may have executed
          with Licensor regarding such Contributions.

       6. Trademarks. This License does not grant permission to use the trade
          names, trademarks, service marks, or product names of the Licensor,
          except as required for reasonable and customary use in describing the
          origin of the Work and reproducing the content of the NOTICE file.

       7. Disclaimer of Warranty. Unless required by applicable law or
          agreed to in writing, Licensor provides the Work (and each
          Contributor provides its Contributions) on an "AS IS" BASIS,
          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
          implied, including, without limitation, any warranties or conditions
          of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
          PARTICULAR PURPOSE. You are solely responsible for determining the
          appropriateness of using or redistributing the Work and assume any
          risks associated with Your exercise of permissions under this License.

       8. Limitation of Liability. In no event and under no legal theory,
          whether in tort (including negligence), contract, or otherwise,
          unless required by applicable law (such as deliberate and grossly
          negligent acts) or agreed to in writing, shall any Contributor be
          liable to You for damages, including any direct, indirect, special,
          incidental, or consequential damages of any character arising as a
          result of this License or out of the use or inability to use the
          Work (including but not limited to damages for loss of goodwill,
          work stoppage, computer failure or malfunction, or any and all
          other commercial damages or losses), even if such Contributor
          has been advised of the possibility of such damages.

       9. Accepting Warranty or Additional Liability. While redistributing
          the Work or Derivative Works thereof, You may choose to offer,
          and charge a fee for, acceptance of support, warranty, indemnity,
          or other liability obligations and/or rights consistent with this
          License. However, in accepting such obligations, You may act only
          on Your own behalf and on Your sole responsibility, not on behalf
          of any other Contributor, and only if You agree to indemnify,
          defend, and hold each Contributor harmless for any liability
          incurred by, or claims asserted against, such Contributor by reason
          of your accepting any such warranty or additional liability.

       END OF TERMS AND CONDITIONS

       APPENDIX: How to apply the Apache License to your work.

          To apply the Apache License to your work, attach the following
          boilerplate notice, with the fields enclosed by brackets "[]"
          replaced with your own identifying information. (Don't include
          the brackets!)  The text should be enclosed in the appropriate
          comment syntax for the file format. We also recommend that a
          file or class name and description of purpose be included on the
          same "printed page" as the copyright notice for easier
          identification within third-party archives.

       Copyright [yyyy] [name of copyright owner]

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

           http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
    """

    // Verbatim from ZIPFoundation LICENSE
    static let mitZIPFoundation = """
    MIT License

    Copyright (c) 2017-2025 Thomas Zoechling (https://www.peakstep.com)

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    """

    // Verbatim from SwiftDataMatrix LICENSE.txt
    static let mitSwiftDataMatrix = """
    Copyright 2026 Daniel Höpfl <daniel@hoepfl.de>

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    """
}

struct ThirdPartyLicensesView: View {
    var body: some View {
        List {
            ForEach(ThirdPartyLicense.allCases) { library in
                NavigationLink {
                    ThirdPartyLicenseDetailView(library: library)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: library.name)
                            .font(.body)
                        Text(verbatim: library.licenseType)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Third-Party Licenses", comment: "Navigation title for list of open source library licenses"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThirdPartyLicenseDetailView: View {
    fileprivate let library: ThirdPartyLicense

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: library.copyright)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(library.licenseText)
                    .font(.footnote)
            }
            .padding()
        }
        .navigationTitle(library.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
