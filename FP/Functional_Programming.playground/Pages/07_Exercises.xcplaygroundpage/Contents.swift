/*:
 # Functional Setters - Exercises
*/

/*:
 1. As we saw with free map on Array, define free map on Optional and use it to compose setters that traverse into an optional field.
*/



/*:
 2. Take a struct, e.g.:
 `struct User {
   let name: String
 }`

 Write a setter for its property. Take (or add) another property, and add a setter for it. What are some potential issues with building these setters?
*/


/*:
 3. Take a struct with a nested struct, e.g.:

 struct Location {
   let name: String
 }

 struct User {
   let location: Location
 }

 Write a setter for userLocationName. Now write setters for userLocation and locationName. How do these setters compose?

*/


/*:
 4. Do first and second work with tuples of three or more values? Can we write first, second, third, and nth for tuples of n values?
*/


 /*:
 5. Write a setter for a dictionary that traverses into a key to set a value.
 */



 /*:
 6. Write a setter for a dictionary that traverses into a key to set a value if and only if that value already exists.
 */


 /*:
 7. What is the difference between a function of the form ((A) -> B) -> (C) -> (D) and one of the form (A) -> (B) -> (C) -> D?
 */


//: [Previous](@previous) |
//: [Next](@next)
