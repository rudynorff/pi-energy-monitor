use std::str;
use std::time::Duration;
use tokio::time::sleep;
use rumqttc::{MqttOptions, AsyncClient, QoS, Outgoing, Event, Packet};
use rusqlite::Connection;


#[tokio::main]
async fn main() {
    let solar: &str = "shellies/solar/relay/0/power";

    let conn = Connection::open("./telemetry.sqlite").unwrap();
    conn.execute(
        "CREATE TABLE IF NOT EXISTS telemetry (id INTEGER PRIMARY KEY, device_id INTEGER NOT NULL, value INTEGER NOT NULL, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)",
        (),
    ).unwrap();
    conn.execute(
        "CREATE TABLE IF NOT EXISTS devices (id INTEGER PRIMARY KEY, name TEXT NOT NULL)",
        (),
    ).unwrap();
    conn.execute(
        "INSERT OR IGNORE INTO devices (id, name) VALUES (1, 'power-grid')",
        (),
    ).unwrap();
    conn.execute(
        "INSERT OR IGNORE INTO devices (id, name) VALUES (2, 'shellies/solar')",
        (),
    ).unwrap();
    conn.execute(
        "INSERT OR IGNORE INTO devices (id, name) VALUES (3, 'gas')",
        (),
    ).unwrap();


    let mut mqttoptions = MqttOptions::new("mqtt-exporter", "192.168.178.122", 1883);
    mqttoptions.set_keep_alive(Duration::from_secs(5));

    let (client, mut eventloop) = AsyncClient::new(mqttoptions, 10);
    client.subscribe(solar, QoS::AtMostOnce).await.unwrap();

    let mut err_counter: i8 = 0;

    loop {
        match eventloop.poll().await {
            Ok(Event::Incoming(Packet::Publish(p))) => {
                let mut device_id: i32 = 1;
                if &p.topic == solar {
                    device_id = 2;
                }

                let payload_str = str::from_utf8(&p.payload).unwrap();
                let payload = payload_str.parse::<f32>().unwrap() as u16;

                println!("Incoming = {:?}, {:?}", p.topic, payload);
                conn.execute(
                    "INSERT INTO telemetry (device_id, value) VALUES (?1, ?2)",
                    (&device_id, payload),
                ).unwrap();
            },
            Ok(Event::Incoming(Packet::PingResp)) |
            Ok(Event::Outgoing(Outgoing::PingReq)) => {},
            Ok(Event::Incoming(_i)) => {},
            Ok(Event::Outgoing(_o)) => {},
            Err(e) => {
                if err_counter == 3  {
                    panic!("Too many error retries");
                }
                err_counter += 1;
                sleep(tokio::time::Duration::from_millis(3000)).await;

                println!("Error = {:?}\nRECONNECTING...\n\n", e);
                client.subscribe(solar, QoS::AtMostOnce).await.unwrap();
            }
        }
    }
}
