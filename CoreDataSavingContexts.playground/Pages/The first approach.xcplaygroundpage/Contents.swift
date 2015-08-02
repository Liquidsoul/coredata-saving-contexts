//: ## A Swift 2.0 Introduction to some `NSManagedObjectContext` subtleties
//:
//: ### Introduction
//:
//: I am quite new at using Core Data.
//: I have started to use it just a few months back, and I've been using it extensively the last couple of month.
//: During this time, I have learned some things about `NSManagedObjectContext` that I want to share.
//: Here, I'll be explaining how the saving mechanism works with multiple contexts created using different methods.
//:
//: We'll be working with very basic Core Data model which will contain only one single entity.
//:
//:		+-----------------+
//:		| Person          |
//:		+-----------------+
//:		| name            |
//:		| wage            |
//:		+-----------------+
//:
//: Here is our context:
//:  * we've got a main context that is used by our controllers
//:  * we want to refresh our data using server requests and store it asynchronously to Core Data (server requests are another topic so we will skip this part)

//: ### The first approach
//: To get started quickly with our topic, let's perform the heavy lifting of creating the model and persistent store coordinator behind the scene:

import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()

//: So now, back to our topic.
//:
//: So let's setup our main context:
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator

//: As we want to share data between contexts, let's create a child context for our background update:
let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
childContext.parentContext = mainContext

//: Let's create a new entity in the child context as if it came from the server:
let person = addPersonToContext(childContext, name: "John", wage: 1000)

//: Now we save our content [1]:
//: [1]: Note that you should use `performBlock()` to execute calls on a `NSManagedObjectContext` to ensure that the correct thread is using it.
try childContext.save()

//: let's check that we have the new content in the main context using a fetch request:
let results = try mainContext.executeFetchRequest(NSFetchRequest(entityName: "Person"))
if let createdPerson = results.first as? Person {
	print(createdPerson)	// "name: John wage:1000"
} else {
	print("Noone there!")
}

//: Yes! Everything seems ok.
//:
//: To be sure, let's just check if everything was saved in the persistent store using a third context as if we were launching our app again:
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

//: and fetch our data:
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(NSFetchRequest(entityName: "Person")).first as? Person {
	print(createdPerson)
} else {
	print("Noone there!")	// "Noone there!"
}

//: Wait, what? There is no data? What happened?
//:
//: Here is the first important lesson to learn.
//: Let's have a look at the official documentation of `save()`:
//:
//: 	Attempts to commit unsaved changes to registered objects to the receiver’s parent store.
//:
//: This can be misleading. When one see `parent store` he can understand `the parent persitent store of my context hierarchy`.
//: However, what is meant by `parent store` is either:
//: * the persistentStoreCoordinator
//: * the parentContext
//:
//: So, if your context was setup with a parent context, changes are commited to his parent but no further.
//: To save it to the persistent store, you'll need to performs `save()` calls on context all the way up in the hierarchy.


//: [Next](@next)
