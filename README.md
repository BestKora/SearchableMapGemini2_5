## SwiftUI iOS Apps “Map with Search” in Tandem with AI Gemini 2.5 Pro Experimental
 <img src="https://github.com/BestKora/SearchableMapGemini2_5/blob/a271460a4856f17822e41df09b13bc852973ee51/SearchableMap.png" width="750">

 I teamed up with Google's brilliant AI, Gemini 2.5 Pro Experimental, to create an app that works like this:
 
* You type a city/place name in the text box at the bottom of the screen.
* With each new letter you type, a list of search suggestions is generated below.
* Press Enter in the search bar and the map shows the found places.
* Select a marker - a Look Around panorama opens at the bottom (if available).
* Clicking on different markers gives us different LookAroundPreviews at the bottom.
* Clicking anywhere on the map outside of LookAroundPreview brings back the search bar with the list of suggestions and starts searching again.
* You can also select the location you need directly from the list of suggestions, in which case a LookAroundPreview also appears at the bottom.

### Ask Gemini 2.5 Pro Experimental (part 1)

<img src="https://github.com/BestKora/SearchableMapGemini2_5/blob/a93cd4590f488d9a35a3d54927f822fa3e0045b6/Stage1.png" width="800">

### Ask Gemini 2.5 Pro Experimental (part 2)

<img src="https://github.com/BestKora/SearchableMapGemini2_5/blob/8db96860e93df8536f389adbd27a043f7433258c/Stage2.png" width="800">

The task has been solved: we have a flawlessly working iOS application “Map with Search”.

### Benefits of using Gemini 2.5 Pro:

1. #### Instant refactoring magic:
   Remember that slightly tangled LocationService? Gemini 2.5 Pro untangled the wires so SheetView wouldn't create its own instance of the service all over the place. It also tidied up the data models. It was like a super-fast assistant that actually enjoys tidying up code. Why is this good? It makes testing easier, prevents weird state bugs, and generally makes code less spaghetti-like. Huge time saver on tedious tasks.

3. #### Framework charmer:
   Need to get search suggestions from MapKit (MKLocalSearchCompleter)? Done. Need to do an actual search (MKLocalSearch)? No problem. Need that cool LookAroundPreview? Gemini knew the right APIs and generated the basic async/await logic faster than I could type import MapKit. He clearly devoured the entire MapKit documentation.

5. #### Proficient at pattern recognition:
   He not only knew the APIs, but also how to use them together. Implementing the "show search button after first search" logic involved managing @State variables and conditional UI rendering - standard stuff, but Gemini put it all together correctly based on the request. Later, he even suggested factoring out complex View logic into separate components or computed properties, which is a great practice.

7. #### Building Blocks:
   He was happy to add features one at a time. We started with a refactoring, added search, added Look Around, added a re-search button... he was pretty good at tracking an evolving codebase.

9. #### Explanatory Ability:
    He could explain the logic and benefits of his particular refactoring approaches.
