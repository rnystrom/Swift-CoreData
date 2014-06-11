Swift & Core Data
=======

I wrote this very simple Core Data application to learn how Swift handles and integrates with some core concepts/tools:

- Singletons, even if they're [smelly](http://www.objc.io/issue-13/singletons.html)
- Core Data stack
- NSFetchedResultsController

One of the most important things that took me *forever* to figure out is that you have to namespace your model class in the ```.xcdatamodel```. This was undocumented. Huge thanks to [Andrew Ebling](https://twitter.com/andyeb/status/476376522400743424) for pointing me in the right direction.

<p align="center"><img title="Pesky Namespacing" src="https://raw.github.com/rnystrom/SwiftDo/master/images/xcdatamodel.png"/></p>

If anyone has any tweaks or improvements, please send some pull requests. I'd love to see what you come up with.

As always, please feel free to reach out on [Twitter](https://twitter.com/_ryannystrom).
