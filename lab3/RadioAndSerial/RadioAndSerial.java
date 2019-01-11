import java.io.IOException;

import net.tinyos.message.*;
import net.tinyos.packet.*;
import net.tinyos.util.*;

public class RadioAndSerial implements MessageListener {

  private MoteIF moteIF;
  
  public RadioAndSerial(MoteIF moteIF) {
    this.moteIF = moteIF;
    this.moteIF.registerListener(new RadioAndSerialMsg(), this);
  }

// 定时发包
  public void sendPackets() {
    int counter = 0;
    RadioAndSerialMsg payload = new RadioAndSerialMsg();
    
    try {
      while (true) {
	System.out.println("Sending packet " + counter);
	payload.set_counter(counter);
	moteIF.send(0, payload);
	counter++;
	try {Thread.sleep(1000);}
	catch (InterruptedException exception) {}
      }
    }
    catch (IOException exception) {
      System.err.println("Exception thrown when sending packets. Exiting.");
      System.err.println(exception);
    }
  }

// 输入发送内容
  public void SendMyPacket()
  {
    BlinkToRadioMsg payload = new BlinkToRadioMsg();
		Scanner in = new Scanner(System.in);

		try {
			while(true) {
				System.out.println("请输入需要发送的内容： ");
				if(in.hasNextInt()){
					counter = in.nextInt();				
				}
        System.out.println("Sending packet " + counter);
				payload.set_counter(counter);
				moteIF.send(0, payload);
				try {
					Thread.sleep(1000);
				}catch(InterruptedException exception){}
			}
		}catch(IOException exception){
			System.err.println("Exception thrown when sending packets. Exiting.");
        	System.err.println(exception);
		}
	}

  public void messageReceived(int to, Message message) {
    RadioAndSerialMsg msg = (RadioAndSerialMsg)message;
    System.out.println("Received packet sequence number " + msg.get_counter());
  }
  
  private static void usage() {
    System.err.println("usage: RadioAndSerial [-comm <source>]");
  }
  
  public static void main(String[] args) throws Exception {
    String source = null;
    if (args.length == 2) {
      if (!args[0].equals("-comm")) {
	usage();
	System.exit(1);
      }
      source = args[1];
    }
    else if (args.length != 0) {
      usage();
      System.exit(1);
    }
    
    PhoenixSource phoenix;
    
    if (source == null) {
      phoenix = BuildSource.makePhoenix(PrintStreamMessenger.err);
    }
    else {
      phoenix = BuildSource.makePhoenix(source, PrintStreamMessenger.err);
    }

    MoteIF mif = new MoteIF(phoenix);
    RadioAndSerial serial = new RadioAndSerial(mif);

    System.out.println("请输入需要进入的模式：");
    System.out.println("1. 自动发送自增数据");
    System.out.println("2. 手动输入数据发送");
    if(in.hasNextInt() == 2)
      serial.SendMyPacket();
    else
    serial.sendPackets();
  }


}
