//: Here we define the [Managed Object Model](https://developer.apple.com/library/mac/documentation/DataManagement/Devpedia-CoreData/managedObjectModel.html).) and our entity programmatically.
//: We're doing this because we are inside a playground so we do not have access to the [Core Data Model Editor](https://developer.apple.com/library/mac/recipes/xcode_help-core_data_modeling_tool/Articles/about_cd_modeling_tool.html).

import CoreData

public class Person: NSManagedObject {
	@NSManaged public var name: NSString
	@NSManaged public var wage: NSNumber

	override public var description: String {
		return "name: \(name)\nwage: \(wage)"
	}
}

func createModel() -> NSManagedObjectModel {
	//: First, let's create our `Person` entity description:
	let personEntityDescription = NSEntityDescription()
	personEntityDescription.name = "Person"
	personEntityDescription.managedObjectClassName = NSStringFromClass(Person)

	//: next, the `name` attribute description:
	let personNameAttributeDescription = NSAttributeDescription()
	personNameAttributeDescription.name = "name"
	personNameAttributeDescription.attributeType = .StringAttributeType
	personNameAttributeDescription.optional = false
	personNameAttributeDescription.indexed = false

	//: and the `wage` attribute description:
	let personWageAttributeDescription = NSAttributeDescription()
	personWageAttributeDescription.name = "wage"
	personWageAttributeDescription.attributeType = .FloatAttributeType
	personWageAttributeDescription.optional = false
	personWageAttributeDescription.indexed = false

	//: Then, we assign our attributes to the entity description:
	personEntityDescription.properties = [personNameAttributeDescription, personWageAttributeDescription]

	//: Finally, we instanciate the model object and add our entity:
	let model = NSManagedObjectModel()
	model.entities = [personEntityDescription]

	//: And we're done!
	return model
}

public func createPersistentStoreCoordinator() throws -> NSPersistentStoreCoordinator {
	let model = createModel()
	let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

	try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)

	return persistentStoreCoordinator
}

public func addPersonToContext(context: NSManagedObjectContext, name: String, wage: Float) -> Person {
	let person = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context) as! Person
	person.name = name
	person.wage = wage
	return person
}