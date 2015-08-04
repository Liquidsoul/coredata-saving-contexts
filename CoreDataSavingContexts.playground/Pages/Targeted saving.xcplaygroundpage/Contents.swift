//: [Previous](@previous)

//: ## Targeted saving
//:
//: So, as before, our main context with our "Billy"

import CoreData

let persistentStoreCoordinator = try createPersistentStoreCoordinator()
let mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
mainContext.persistentStoreCoordinator = persistentStoreCoordinator
let ourOtherPerson = addPersonToContext(mainContext, name: "Billy")

//: Therefore, to prevent "Billy" to be saved while we just wanted to save "John", we will not create our editing context from the main one.
//: We will create what I call a *sibling* context which share the same store as the main one:

let siblingContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
siblingContext.persistentStoreCoordinator = persistentStoreCoordinator
let person = addPersonToContext(siblingContext, name: "John")

//: Now, all we have to do is save the sibling context:
try siblingContext.save()

//: Let's check that we can access our "John" from our main context:
let fetchRequest = NSFetchRequest(entityName: "Person")
fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "John")
if let createdPerson = try mainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)	// "name: John"
} else {
	print("Noone there!")
}

//: Yes! Now let's see if "Billy" was saved:
let secondLaunchMainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
secondLaunchMainContext.persistentStoreCoordinator = persistentStoreCoordinator

fetchRequest.predicate = NSPredicate(format:"%K like %@", "name", "Billy")
if let createdPerson = try secondLaunchMainContext.executeFetchRequest(fetchRequest).first as? Person {
	print(createdPerson)
} else {
	print("Noone there!")	// "Noone there!"
}

//: We did it!
//:
//: ## Conclusion
//: 
//: We learned that:
//: 
//: * calling `save()` on a context will only send changes one step up the hierarchy
//: * `save()` will commit changes contained in the whole context
//:
//: As a side note: for the sake of simplicity here, we have only worked with entity insertion.
//: When you start playing with entity attributes, you'll need to perform some `refreshObject()` calls to see the saved values in other contexts.
