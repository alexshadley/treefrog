package orm

type Client interface {
	CreateClass(name, superclass string) error
	AlterClass(name, attribute, attributeValue string) error
	AddProperty(class, name string, propertyType string, linkType string, constraints map[string]string) error
	CreateVertex(class string, properties string) (string, error)
	CreateEdge(class string, from string, to string, properties string) (string, error)
}