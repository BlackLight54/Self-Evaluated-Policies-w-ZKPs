Given the rising interest in data ownership and security, Zero Knowledge proof (ZKP) protocols have emerged as a cornerstone of cryptographic research and are becoming increasingly widely used. As performant ZKPs are convoluted to design, frameworks for higher-level, mostly imperative languages have been proposed for generating ZKPs.

At the same time, there has been a resurgence of interest in declarative programming languages in the context of access control, authorization, and general policy enforcement and evaluation. These fields closely relate to privacy and would greatly benefit from privacy-preserving techniques.

There is a gap in integrating ZKPs with declarative programming languages, especially in contexts requiring rigorous policy enforcement. We introduce the concept of Self-Evaluated Policies: the evaluated policy, its result computed by the subject, the proof of computation, and all public inputs are cryptographically bound together and can by themselves serve as proof of compliance. We aim to answer the pivotal question: How can one seamlessly harness the strengths of Prolog's expressive power while ensuring the robust privacy guarantees of ZKPs within a Self-Evaluated Policy?

In this paper, we present a high-level ZKP framework tailored to Prolog. By leveraging Prolog's meta-interpretation capabilities and by constructing an efficient representation of the evaluations, we bridge the gap between expressive policy definition and the robust privacy assurances of ZKPs. Our framework focuses on protecting private input data for a public policy. The architecture can efficiently verify Prolog proof trees and provides a mechanism to generate arithmetic circuits specific to a Prolog program, which is able to validate the proof tree while preserving the privacy of underlying data.

We detail the implementation of our framework over an example financial use case, specifically, privacy-enhanced governmental support allocation for residential energy expenses. By bundling the result of the evaluation into a Self-Evaluated Policy together with the proof and public inputs, the subject can prove how much support they are entitled to without revealing their underlying consumption.

Our approach highlights the possibilities of integrating Prolog with ZKPs and offers insights for advancements in privacy-preserving policy evaluations. Our framework serves as a reference for future research, with potential applications in domains like Self-Sovereign Identities, Constraint Logic Programming, and beyond.

%% Self-evaluated policies using Zero-Knowledge proofs %%
%% Önkiértékelésű eljárásrendek Tudásmentes Bizonyítás-támogatása%%


%% szekció 1. információs rendszerek, 2. intelligens rendszerek %%
%% tudásmentes bizonyítások, prolog, Önrendelkezésű identitás, declarative policies %%

