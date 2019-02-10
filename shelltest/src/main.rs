extern crate clap;
use clap::{Arg, App, SubCommand};

fn main() {
    let matches = App::new("myapp")
        .version("1.0")
        .author("Kevin K. <kbknapp@gmail.com>")
        .about("Does awesome things")
        .args_from_usage(
            "-c, --config=[FILE] 'Sets a custom config file'
                              <INPUT>              'Sets the input file to use'
                              -v...                'Sets the level of verbosity'")
        .subcommand(SubCommand::with_name("test")
            .about("controls testing features")
            .version("1.3")
            .author("Someone E. <someone_else@other.com>")
            .arg_from_usage("-d, --debug 'Print debug information'"))
        .get_matches();
//
//    let matches = clap_app!(myapp =>
//        (version: "1.0")
//        (author: "Kevin K. <kbknapp@gmail.com>")
//        (about: "Does awesome things")
//        (@arg CONFIG: -c --config +takes_value "Sets a custom config file")
//        (@arg INPUT: +required "Sets the input file to use")
//        (@arg debug: -d ... "Sets the level of debugging information")
//        (@subcommand test =>
//            (about: "controls testing features")
//            (version: "1.3")
//            (author: "Someone E. <someone_else@other.com>")
//            (@arg verbose: -v --verbose "Print test information verbosely")
//        )
//    ).get_matches();

    // Same as before...
    println!("Hello, world!");
}
