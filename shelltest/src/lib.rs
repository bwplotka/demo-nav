use std::fs::File;
use std::thread;
use std::time;
use std::future;
use std::process::{Child, Command, Stdio};

pub enum Shell {
    Current,
}

pub enum Handle {
    Stdout,
    Stderr,
    File(String),
}

pub struct Suite {
    shell: Shell,
    script: String,
    args: Vec<String>,

    stderr: File,
    stdout: File,
    child: Option<Child>,
}

pub fn new(script: &str) -> Suite {
    File::open(script).expect(
        format!(
            r#"assertion failed: `script {} being present`
    >>"#,
            script
        )
        .as_str(),
    );

    Suite {
        shell: Shell::Current,
        script: String::from(script),
        args: [].to_vec(),

        stderr: File::create("/tmp/something-stderr").expect("failed to create tmp file"),
        stdout: File::create("/tmp/something-stdout").expect("failed to create tmp file"),
        child: None,
    }
}

impl Suite {
    pub fn expect(mut self, handle: Handle, s: &str) -> Suite {
        if let None = self.child {
            self.exec();
        }

        self
    }

    fn exec(&mut self) {
        self.child = Some(Command::new(self.script.clone())
            .args(self.args.clone())
            .stderr(Stdio::from(self.stderr))
            .stdout(Stdio::from(self.stdout))
            .spawn()
            .expect(
                format!(
                    r#"assertion failed: `cmd {} exec failed`
    >>"#, self.stdout,
                )
                .as_str(),
            ));

        //future::
    }

    fn waitUntilIdle(self) -> bool {
        let mut ln;
        while self.stderr.metadata().expect("af").len() != ln {
            ln = self.stderr.metadata().expect("af").len();
            thread::sleep(time::Duration::from_float_secs(1.0));
        }

        self.stderr.metadata().expect("af").len() != ln
    }
}

impl Drop for Suite {
    fn drop(&mut self) {}
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn outputs() {
        new("./src/testdata/script1.sh")
            .expect(Handle::Stdout, "test output");
    }
}
