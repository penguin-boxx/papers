::: {custom-style="ispHeader1"}
Effect Systems as a Mechanism for Managing Contextual Free Variables: A Unifying Perspective
:::

::: {custom-style="ispAuthor"}
A. S. Stoyan, ORCID: 0009-0004-6935-1447 \<a.stoyan@hse.ru\>
:::

::: {custom-style="ispAuthor"}
National Research University Higher School of Economics, 3A, Kantemirovskaya Str., Saint Petersburg, 194100, Russia
:::

::: {custom-style="ispAnotation"}
**Abstract.** Effect systems lift information about a program's computational effects to the type level: they sharpen abstraction boundaries and let the compiler verify that an effectful computation runs in a context that supports it. Nevertheless, static effect tracking has not yet become common practice: the leading approaches — effect rows, capabilities, and modal types — have evolved as unrelated constructions, and a language designer struggles to see the overall design space. We propose a unifying perspective: an effect system is a mechanism for managing the contextual free variables of a computation, i.e., dependencies that are not passed as ordinary arguments but must be resolved by the execution context. Such a variable goes through a lifecycle of two phases: it arises pending, as an unfulfilled contextual requirement, and once bound, its value can be captured by a closure as a lexical free variable. Families of effect systems differ in which phases and transitions of this lifecycle they make explicit in types. Classical row-based systems (Koka, Links, Java's checked exceptions) keep the variables pending and cannot express capture. Capability-based systems allow capture but forbid a captured variable from escaping its context by means of type-level escape analysis. Modal systems, instead of forbidding the escape, release the escaped variable again, re-exposing it in the type as a contextual requirement. Comparing the families along this single axis shows that the static discipline of an effect system can be assembled from two mechanisms already familiar to practitioners: implicit parameters and type-level escape analysis.
:::

::: {custom-style="ispAnotation"}
**Keywords:** effect systems; computational effects; contextual free variables; free variables; implicit parameters; escape analysis; capabilities; effect rows; modal types; type systems; contextual polymorphism
:::

::: {custom-style="ispAnotation"}
**For citation:** Stoyan A.S. Effect Systems as a Mechanism for Managing Contextual Free Variables: A Unifying Perspective. Trudy ISP RAN/Proc. ISP RAS, 2026, vol. 37, issue 1, pp. 1–23 (in Russian). DOI: 10.15514/ISPRAS-2026-XX(X)-XX
:::
