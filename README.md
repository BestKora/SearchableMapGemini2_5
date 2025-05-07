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
   Remember that slightly tangled LocationService? Gemini suggested dependency injection, basically untangling the wires so SheetView wasn't creating its own service instance willy-nilly. It cleaned up data models too. It was like having a super-fast assistant who actually enjoys tidying up code. Why is this good? It makes testing easier, prevents weird state bugs, and generally makes the code less spaghetti-like. Huge time saver on the boring stuff.

3. #### Framework Whisperer:
   Need to fetch MapKit search suggestions (MKLocalSearchCompleter)? Done. Need to perform an actual search (MKLocalSearch)? No problem. Need that cool LookAroundPreview? Gemini knew the APIs and generated the basic async/await fetching logic faster than I could type the import statement. It clearly had ingested the MapKit manuals.

5. #### Pattern Recognition Pro:
   Beyond just knowing APIs, it understood how to use them together. Implementing the "show a search button after the first search" logic involved managing @State variables and conditional UI – standard stuff, but Gemini pieced it together correctly based on the request. It even suggested extracting UI chunks into computed properties later on, which is good practice.

7. #### Building Blocks:
   It happily added features sequentially. We started with refactoring, added search, added Look Around, added the re-search button... it kept track of the evolving codebase reasonably well.

9. #### Explanatory Ability:
    He could explain the logic and benefits of his particular refactoring approaches.

   ### Downsides of using Gemini 2.5 Pro:

1. #### Syntactic stumbling blocks:
   Sometimes Gemini would confidently produce code with small but fatal flaws. The most memorable was ignoresSafeArea(edges: .top, treatingAs: .edge). The treatingAs parameter? It doesn't exist! It was hallucinating a perfectly plausible (but invalid) modifier argument. This was a tricky bug that was not easy to find. Misplacing onDismiss was another example.

3. #### Context juggling:
   While it mostly got it right, when debugging a complex compiler error it felt like it was almost losing track of which modifiers were being applied where, requiring clearer instructions from me. Its short-term memory occasionally broke under the strain.

5. #### Confidence is Key (Even if Wrong):
   The AI ​​presents both brilliant and buggy code with exactly the same level of "Here you go, human!" confidence. There is no "Hmm, I'm not sure about this part...", which means you have to be a skeptic, a tester, someone who double-checks its work.

   ###  Philosophical conclusion

At the end of our digital tandem, it became clear: Gemini 2.5 Pro Experimental is not a magic wand that fulfills the developer's wishes, but rather a talented, but sometimes absent-minded intern. It can generate boilerplate code at lightning speed and even offer elegant architectural solutions, but when it comes to the tricky traps of declarative SwiftUI in the form of complex View hierarchies or long chains of modifiers, it still needs the firm hand of an experienced mentor.



   
