# flutris

This is a weird one. This is the server and frontend code for the Flutris game. The
only reason the backend code has the flutter engine installed is for the layout and
validation logic.

### Why don't you use freezed?

Every time you modify a model, you must stop what you're doing and run the build_runner.
To me, this breaks my flow, and vastly increases the chance that I reach for my phone or
get distracted. Furthermore, the error messages from freezed are cryptic, and the package
itself doesn't solve any problem beyond merely reducing boilerplace. Boilerplate, that is,
until you need custom logic inside toJson/fromJson. At which point, it becomes major pain.
With LLMs, the manual labor of having to type out these data classes becomes irrelevant.

### Why don't you use a state management library?

Why use many dependencies when few dependencies do trick?

### Why use the Flutter engine as a layout interpreter?

In my eyes, there were a few ways to solve this problem. 

1. Using static code analysis
2. Using Dart's AST package
3. Letting Flutter handle the layout for me

1 and 2 both suffer the problem of higher complexity and limited layout posibilities. 
They are both absolutely more scalable and would be my first choice if the solution was
easy. The biggest reason why I opted for using Flutter directly, was that ChatGPT
one-shotted the layout engine, and I rolled with it. In my eyes, that was the biggest
technical challenge besides executing Flutter string code eval() style. So by getting that
out of the way, a major blocker was addressed.

### Why Dart on the BE?

E2E type safety, shared types, shared libs. I would have loved to have tried something else
to learn another lang, but Dart was just too appealing here.
