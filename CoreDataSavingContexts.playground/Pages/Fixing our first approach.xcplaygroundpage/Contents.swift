//: [Previous](@previous)

//: ### Fixing our first approach
//:

//: So, we have our initial setup.

import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator

//: But to spice it a little, let's create another entity that will be living in the main context.
//: Note that this entity could've come from another child context:
let ourOtherPerson = addPersonToContext(mainContext, name: "Billy", wage: 2000)

//: And then let's say we've got our server data we want to save in the persistent store:
let childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
childContext.parentContext = mainContext
let person = addPersonToContext(childContext, name: "John", wage: 1000)

//: Now, as we've learned before, we save our content from the child to the main context[1]:
try childContext.save()
try mainContext.save()

//: So now we should have saved our "John" in the persistent store, let's check that:
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

let fetchRequest = NSFetchRequest(entityName: "Person")
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "John")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: John wage:1000"
} else {
	print("Noone there!")
}

//: Problem solved!
//:
//: But wait... what happened to our "Billy". We wanted to store "John" into the persitent store, not "Billy":
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "Billy")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: Billy wage:2000"
} else {
	print("Noone there!")
}

//: Oh no! We've saved "Billy" as well!
//:
//: Yet, this seems coherent with the fact that, as we've performed a `save()` on the main context, *all* objects it contains are saved.
//:
//: So what can we do if we only want to save John without saving Billy?

//: [Next](@next)
