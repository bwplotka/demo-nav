use std::io;
use std::fs::File;

pub enum Shell {
    Current,
}

pub struct Suite {
   shell: Shell,
   script: String
}

impl Suite {
    fn setup(filename: &str) -> io::Result<Suite> {
        match File::open(filename)  {
            Err(err) => return Err(err),
            _ => (),
        }

        Ok(Suite {
            shell: Shell::Current,
            script: String::from(filename),
        })
    }
}

impl Drop for Suite {
    fn drop(&mut self) {
        println!("Teardown Suite with data `{}`!", self.script)
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn outputs() {
        let mut s = super::Suite::setup("./testdata/script1.sh");

        assert_eq!(2 + 2, 4);
    }
}
