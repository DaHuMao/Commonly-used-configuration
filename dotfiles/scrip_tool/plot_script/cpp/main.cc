#include <chrono>
#include "plot_client.h"
//************************example***********************************
int main() {
    plot_plot::set_ip_address("172.24.220.151", 9600);
    const size_t count = 2000;
    const size_t max_val = 50;
    int val = 0;
    int flag = 1;
    for (size_t i = 0; i < count; ++i) {
        LOG_I("media_info") << "send_speak_count:" << val << " "
                     << "aec_speak_count:" << val + 1 << " "
                     << "sssadsa" << " "
                     << "RTT:" << val + 3 << " "
                     << "send_speak_energy:" << val + 10 << " ";
        if (i % 2 == 0) {
            LOG_I("test") << "bb:" << val - 100;
        }
        if (val <= 0) {
            flag = 1;
        } else if (val >= max_val) {
            flag = -1;
        }
        val += flag;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }
}

