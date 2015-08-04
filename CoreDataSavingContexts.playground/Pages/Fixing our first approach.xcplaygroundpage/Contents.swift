//: [Previous](@previous)

//: ## Fixing our first approach
//:

//: So, we have our initial setup.

import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator

//: But to spice it a little, let's create another entity that will be living in the main context.
//: For example, this entity could've come from another child context:
let ourOtherPerson = addPersonToContext(mainContext, name: "Billy")

//: Now, we continue as before with the server data we want to save in the persistent store:
let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
childContext.parentContext = mainContext
let person = addPersonToContext(childContext, name: "John")

//: Now, as we've learned before, we save our content in the child context and then in the main context[^3]:
try childContext.save()
try mainContext.save()

//: We have saved our "John" in the persistent store, let's check that:
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

let fetchRequest = NSFetchRequest(entityName: "Person")
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "John")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

//: Problem solved!
//:
//: But wait... what happened to our "Billy". We wanted to store only "John" into the persitent store, not "Billy":
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "Billy")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: Billy"
} else {
	print("Noone there!")
}

//: Oh no! We've saved "Billy" as well!
//:
//: Yet, this seems coherent with the fact that, as we've performed a `save()` on the main context, *all* objects it contains are saved.
//:
//: So what can we do if we only want to save John without saving Billy?
//:
//: [^3]: as told before[^2], don't forget to use `performBlock()` to call CoreData context code

//: [Next](@next)
