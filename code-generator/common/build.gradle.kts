plugins {
    id("hu.bme.kotlin-application-conventions")
    antlr
}
dependencies {
    implementation("org.json:json:20230227")
    implementation("org.antlr:antlr4:4.13.1")
    // https://mvnrepository.com/artifact/com.owlike/genson
    implementation("com.owlike:genson:1.6")

    antlr("org.antlr:antlr4:4.13.1")
}

tasks.named("compileKotlin") {
    dependsOn("generateGrammarSource")
}

tasks.named("compileTestKotlin") {
    dependsOn("generateTestGrammarSource")
}

tasks.test {
    useJUnitPlatform()
}