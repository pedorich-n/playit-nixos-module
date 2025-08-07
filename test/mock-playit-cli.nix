{
  runCommandLocal,
  simple-http-server,
  lib,
  ...
}:
runCommandLocal "mock-playit-cli"
  {
    meta.mainProgram = "playit-cli";
  }
  ''
    mkdir -p $out/bin
    bin=$out/bin/playit-cli

    echo "${lib.getExe simple-http-server} --port 9213" >> $bin
    chmod +x $bin
  ''
