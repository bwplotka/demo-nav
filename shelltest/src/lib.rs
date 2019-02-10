use std::fs::File;
use std::thread;
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

    child: Option<Child>,
    handle: thread::JoinHandle<Send + 'static {Builder::new().spawn(f).unwrap() }>,
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

        child: None,
        handle: thread::JoinHandle,
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
        let handle = thread::spawn(|| {
            for i in 1..10 {
                println!("hi number {} from the spawned thread!", i);
                thread::sleep(Duration::from_millis(1));
            }
        });
        for i in 1..5 {
            println!("hi number {} from the main thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
        handle.join().unwrap();





        self.child = Some(Command::new(self.script.clone())
            .args(self.args.clone())
            .stderr(Stdio::from())
            .
            .spawn()
            .expect(
                format!(
                    r#"assertion failed: `cmd {} exec failed`
    >>"#,
                    self.script.as_str()
                )
                .as_str(),
            ));

        self.child.expect("").
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
