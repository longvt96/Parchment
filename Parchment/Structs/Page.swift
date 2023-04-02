import Foundation
import UIKit
import SwiftUI

/// The `Page` struct represents a single page in a `PageView`.
/// It contains the view hierarchy for the header and body of the
/// page. You can initialize it with a custom SwiftUI header view
/// using the `init(header:content:)` initializer, or just use
/// the default title initializer `init(_:content:)`.
///
/// Usage:
/// ```
/// Page("Page Title") {
///     Text("This is the content of the page.")
/// }
///
/// Page { _ in
///     Image(systemName: "star.fill")
/// } content: {
///     Text("This is the content of the page.")
/// }
/// ```
///
/// Note that the header and content parameters in both
/// initializers are closures that return the view hierarchy for
/// the header and body of the page, respectively.
@available(iOS 13.0, *)
public struct Page {
    let reuseIdentifier: String
    let registerCell: (UICollectionView) -> Void
    let headerHostingController: (PagingOptions) -> UIViewController
    let header: (PagingOptions, PageState, UIViewController) -> Void
    let content: () -> UIViewController

    /// Creates a new page with the given header and content views.
    ///
    /// - Parameters:   
    ///   - header: A closure that takes a `PageState` instance as
    ///     input and returns a `View` that represents the header view
    ///     for the page. The `PageState` instance will be updated as
    ///     the page is scrolled, allowing the header view to adjust
    ///     its appearance accordingly.
    ///   - content: A closure that returns a `View` that represents
    ///     the content view for the page.
    ///
    ///    - Returns: A new `Page` instance with the given header and content views.
    public init<Header: View, Content: View>(
        @ViewBuilder header: @escaping (PageState) -> Header,
        @ViewBuilder content: () -> Content
    ) {
        let content = content()

        let reuseIdentifier = "CellIdentifier-\(String(describing: Header.self))"
        self.reuseIdentifier = reuseIdentifier

        self.registerCell = { collectionView in
            collectionView.register(
                PageItemCell.self,
                forCellWithReuseIdentifier: reuseIdentifier
            )
        }

        self.headerHostingController = { options in
            let state = PageState(progress: 0, isSelected: false)
            let view = PageCustomView(
                content: header(state),
                options: options,
                state: state
            )
            return UIHostingController(rootView: view)
        }

        self.header = { options, state, viewController in
            let hostingController = viewController as! UIHostingController<PageCustomView<Header>>
            let view = PageCustomView(
                content: header(state),
                options: options,
                state: state
            )
            hostingController.rootView = view
        }

        self.content = {
            UIHostingController(rootView: content)
        }
    }

    /// Creates a new page with the given localized title and content views.
    /// 
    /// - Parameters:
    ///   - titleKey: A `LocalizedStringKey` that represents the
    ///     localized title for the page. The title will be shown in a
    ///     `Text` view as the header of the page.
    ///   - content: A closure that returns a `View` that represents
    ///     the content view for the page.
    ///
    /// - Returns: A new `Page` instance with the given title and content views.
    public init<Content: View>(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        let content = content()
        
        let reuseIdentifier = "CellIdentifier-PageTitleView"
        self.reuseIdentifier = reuseIdentifier

        self.registerCell = { collectionView in
            collectionView.register(
                PageItemCell.self,
                forCellWithReuseIdentifier: reuseIdentifier
            )
        }

        self.headerHostingController = { options in
            let header = PageTitleView(
                content: Text(titleKey),
                options: options,
                progress: 0
            )
            return UIHostingController(rootView: header)
        }

        self.header = { options, state, viewController in
            let hostingController = viewController as! UIHostingController<PageTitleView>
            let header = PageTitleView(
                content: Text(titleKey),
                options: options,
                progress: state.progress
            )
            hostingController.rootView = header
        }

        self.content = {
            UIHostingController(rootView: content)
        }
    }

    /// Creates a new page with the given title and content views.
    ///
    /// - Parameters:
    ///   - titleKey: A `StringProtocol` instance that represents
    ///     the title for the page. The title will be shown in a
    ///     `Text` view as the header of the page.
    ///   - content: A closure that returns a `View` that represents
    ///     the content view for the page.
    ///
    /// - Returns: A new `Page` instance with the given title and content views.
    public init<Title: StringProtocol, Content: View>(
        _ title: Title,
        @ViewBuilder content: () -> Content
    ) {
        let content = content()

        let reuseIdentifier = "CellIdentifier-PageTitleView"
        self.reuseIdentifier = reuseIdentifier

        self.registerCell = { collectionView in
            collectionView.register(
                PageItemCell.self,
                forCellWithReuseIdentifier: reuseIdentifier
            )
        }

        self.headerHostingController = { options in
            let header = PageTitleView(
                content: Text(title),
                options: options,
                progress: 0
            )
            return UIHostingController(rootView: header)
        }

        self.header = { options, state, viewController in
            let hostingController = viewController as! UIHostingController<PageTitleView>
            let header = PageTitleView(
                content: Text(title),
                options: options,
                progress: state.progress
            )
            hostingController.rootView = header
        }
        
        self.content = {
            UIHostingController(rootView: content)
        }
    }
}

@available(iOS 13.0, *)
struct PageCustomView<Content: View>: View {
    let content: Content
    let options: PagingOptions
    let state: PageState

    var body: some View {
        content
            .foregroundColor(Color(UIColor.interpolate(
                from: options.textColor,
                to: options.selectedTextColor,
                with: state.progress
            )))
    }
}

@available(iOS 13.0, *)
struct PageTitleView: View {
    let content: Text
    let options: PagingOptions
    let progress: CGFloat

    var body: some View {
        content
            .fixedSize()
            .padding(.horizontal, options.menuItemLabelSpacing)
            .foregroundColor(Color(UIColor.interpolate(
                from: options.textColor,
                to: options.selectedTextColor,
                with: progress
            )))
    }
}
